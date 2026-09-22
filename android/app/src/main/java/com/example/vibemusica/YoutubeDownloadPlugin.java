package com.example.vibemusica;

import android.content.Context;
import android.media.MediaMetadataRetriever;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;
import androidx.annotation.NonNull;
import com.yausername.youtubedl_android.YoutubeDL;
import com.yausername.youtubedl_android.YoutubeDLRequest;
import com.yausername.ffmpeg.FFmpeg;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import java.io.File;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.atomic.AtomicBoolean;
import kotlin.Unit;

/** Runs yt-dlp inside the app, without a remote server or shared-storage access. */
public final class YoutubeDownloadPlugin implements FlutterPlugin, MethodChannel.MethodCallHandler {
    private final Handler main = new Handler(Looper.getMainLooper());
    private final ExecutorService worker = Executors.newSingleThreadExecutor();
    private final AtomicBoolean busy = new AtomicBoolean(false);
    private final AtomicBoolean cancelled = new AtomicBoolean(false);
    private Context context;
    private MethodChannel channel;
    private volatile String processId;
    private boolean prepared = false;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        context = binding.getApplicationContext();
        channel = new MethodChannel(binding.getBinaryMessenger(), "vibemusica/youtube_downloads");
        channel.setMethodCallHandler(this);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        if (call.method.equals("cancel")) {
            cancelled.set(true);
            String active = processId;
            if (active != null) YoutubeDL.getInstance().destroyProcessById(active);
            result.success(null);
            return;
        }
        if (!call.method.equals("download")) { result.notImplemented(); return; }
        String id = call.argument("videoId");
        if (id == null || !id.matches("[a-zA-Z0-9_-]{11}")) {
            result.error("INVALID_ID", "Invalid YouTube video ID.", null);
            return;
        }
        if (!busy.compareAndSet(false, true)) {
            result.error("BUSY", "Another download is running.", null);
            return;
        }
        cancelled.set(false);
        worker.execute(() -> download(id, result));
    }

    private void prepare() throws Exception {
        if (prepared) return;
        YoutubeDL.getInstance().init(context);
        FFmpeg.getInstance().init(context);
        try {
            YoutubeDL.getInstance().updateYoutubeDL(context, YoutubeDL.UpdateChannel._STABLE);
        } catch (Throwable error) {
            Log.w("VibeDownloads", "Extractor update unavailable; using bundled version.");
        }
        prepared = true;
        Log.i("VibeDownloads", "yt-dlp ready: " + YoutubeDL.getInstance().versionName(context));
    }

    private void download(String id, MethodChannel.Result result) {
        File root = new File(context.getFilesDir(), "youtube_audio");
        File pending = new File(root, id + ".pending");
        String successPath = null;
        String errorCode = null;
        String errorMessage = null;
        try {
            if (!root.exists() && !root.mkdirs()) throw new IOException("Cannot create audio storage");
            deleteTemporary(pending);
            if (!pending.mkdirs()) throw new IOException("Cannot create temporary audio storage");
            prepare();
            if (cancelled.get()) throw new InterruptedException();
            processId = "vibemusica-" + id;
            YoutubeDLRequest request = new YoutubeDLRequest("https://www.youtube.com/watch?v=" + id);
            request.addOption("--ignore-config");
            request.addOption("--no-playlist");
            request.addOption("--no-mtime");
            request.addOption("--no-overwrites");
            request.addOption("--socket-timeout", "20");
            request.addOption("--retries", "2");
            request.addOption("--fragment-retries", "2");
            request.addOption("--abort-on-unavailable-fragment");
            request.addOption("-f", "bestaudio[ext=m4a]/bestaudio[ext=webm]");
            request.addOption("-o", new File(pending, id + ".%(ext)s").getAbsolutePath());
            YoutubeDL.getInstance().execute(request, processId, (percent, eta, line) -> {
                if (cancelled.get()) {
                    YoutubeDL.getInstance().destroyProcessById("vibemusica-" + id);
                }
                main.post(() -> {
                    if (channel == null) return;
                    Map<String, Object> event = new HashMap<>();
                    event.put("videoId", id);
                    event.put("progress", Math.max(0.0, Math.min(0.99, percent / 100.0)));
                    channel.invokeMethod("progress", event);
                });
                return Unit.INSTANCE;
            });
            if (cancelled.get()) throw new InterruptedException();
            File completed = new File(pending, id + ".m4a");
            if (!completed.exists()) completed = new File(pending, id + ".webm");
            validateAudio(completed);
            if (cancelled.get()) throw new InterruptedException();
            File destination = new File(root, completed.getName());
            if (!completed.renameTo(destination)) throw new IOException("Cannot save completed audio");
            successPath = destination.getAbsolutePath();
        } catch (Throwable error) {
            final boolean wasCancelled = cancelled.get() || error instanceof InterruptedException;
            String detail = String.valueOf(error.getMessage());
            // Never log signed URLs, cookies, or full extractor command output.
            String message = wasCancelled ? "Download cancelled."
                    : detail.contains("403") ? "YouTube rejected this audio download (HTTP 403)."
                    : detail.toLowerCase().contains("sign in") ? "This track requires signing in to YouTube."
                    : error instanceof IOException ? "Could not save audio. Check free storage space."
                    : "YouTube could not provide downloadable audio for this track.";
            Log.w("VibeDownloads", error.getClass().getSimpleName() + ": " + message);
            String diagnostic = detail.replaceAll("https?://\\S+", "[URL]");
            Log.w("VibeDownloads", diagnostic.substring(0, Math.min(1000, diagnostic.length())));
            errorCode = wasCancelled ? "CANCELLED" : "DOWNLOAD_FAILED";
            errorMessage = message;
        } finally {
            processId = null;
            deleteTemporary(pending);
            busy.set(false);
        }
        final String path = successPath;
        final String code = errorCode;
        final String message = errorMessage;
        main.post(() -> {
            if (code == null) result.success(path);
            else result.error(code, message, null);
        });
    }

    private static void validateAudio(File file) throws Exception {
        if (!file.isFile() || file.length() == 0) throw new IOException("Audio file is empty");
        MediaMetadataRetriever media = new MediaMetadataRetriever();
        try {
            media.setDataSource(file.getAbsolutePath());
            String duration = media.extractMetadata(MediaMetadataRetriever.METADATA_KEY_DURATION);
            if (duration == null || Long.parseLong(duration) <= 0) throw new IOException("Audio is incomplete");
        } finally { media.release(); }
    }

    private static void deleteTemporary(File file) {
        if (file.isDirectory()) {
            File[] children = file.listFiles();
            if (children != null) for (File child : children) deleteTemporary(child);
        }
        if (file.exists()) file.delete();
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        cancelled.set(true);
        if (processId != null) YoutubeDL.getInstance().destroyProcessById(processId);
        channel.setMethodCallHandler(null);
        channel = null;
        worker.shutdownNow();
    }
}
