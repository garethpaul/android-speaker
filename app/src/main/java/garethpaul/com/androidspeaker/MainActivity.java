package garethpaul.com.androidspeaker;

import android.app.Activity;
import android.media.AudioManager;
import android.media.MediaPlayer;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Toast;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;


public class MainActivity extends Activity {
    private static final String TAG = "androidspeaker";
    private static final String TTS_ENDPOINT = "https://translate.google.com/translate_tts?tl=en&q=";

    private MediaPlayer player;
    private EditText textInput;

    static String buildTextToSpeechUrl(String text) throws UnsupportedEncodingException {
        return TTS_ENDPOINT + URLEncoder.encode(text, "UTF-8");
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        textInput = (EditText) findViewById(R.id.editText);

        final Button button = (Button) findViewById(R.id.button);
        button.setOnClickListener(new View.OnClickListener() {
            public void onClick(View v) {
                playText(textInput.getText().toString());
            }
        });

    }

    private void playText(String text) {
        if (text.trim().length() == 0) {
            Toast.makeText(this, "Enter text to speak.", Toast.LENGTH_SHORT).show();
            return;
        }

        releasePlayer();
        MediaPlayer nextPlayer = new MediaPlayer();
        nextPlayer.setAudioStreamType(AudioManager.STREAM_MUSIC);

        try {
            nextPlayer.setDataSource(buildTextToSpeechUrl(text));
            nextPlayer.prepare();
            nextPlayer.start();
            player = nextPlayer;
        } catch (UnsupportedEncodingException e) {
            handlePlaybackFailure(nextPlayer, e);
        } catch (IllegalArgumentException e) {
            handlePlaybackFailure(nextPlayer, e);
        } catch (IllegalStateException e) {
            handlePlaybackFailure(nextPlayer, e);
        } catch (IOException e) {
            handlePlaybackFailure(nextPlayer, e);
        }
    }

    private void handlePlaybackFailure(MediaPlayer failedPlayer, Exception error) {
        failedPlayer.release();
        Toast.makeText(this, "Unable to play speech audio.", Toast.LENGTH_SHORT).show();
        Log.w(TAG, "Unable to play TTS audio.", error);
    }

    private void releasePlayer() {
        if (player != null) {
            player.release();
            player = null;
        }
    }

    @Override
    protected void onDestroy() {
        releasePlayer();
        super.onDestroy();
    }
}
