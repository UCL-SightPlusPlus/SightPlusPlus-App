package ucl.org.sight_plus_plus_team.sight_plus_plus;

import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.content.Intent;
import android.os.Build;
import android.os.Bundle;

import androidx.annotation.Nullable;
import androidx.annotation.RequiresApi;

import io.flutter.embedding.android.FlutterActivity;

public class MainActivity extends FlutterActivity {

    Intent serviceIntent;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        serviceIntent = new Intent(MainActivity.this, SightPlusPlusService.class);
        if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(serviceIntent);
        }else{
            startService(serviceIntent);
        }


    }
}
