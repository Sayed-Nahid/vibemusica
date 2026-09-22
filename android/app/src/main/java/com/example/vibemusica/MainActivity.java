package com.example.vibemusica;

import androidx.annotation.NonNull;
import com.ryanheise.audioservice.AudioServiceActivity;
import io.flutter.embedding.engine.FlutterEngine;

public class MainActivity extends AudioServiceActivity {
    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        if (!flutterEngine.getPlugins().has(YoutubeDownloadPlugin.class)) {
            flutterEngine.getPlugins().add(new YoutubeDownloadPlugin());
        }
    }
}
