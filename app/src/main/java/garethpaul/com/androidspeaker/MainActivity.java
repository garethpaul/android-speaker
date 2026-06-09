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
    private static final int MAX_SPEECH_TEXT_LENGTH = 200;

    private MediaPlayer player;
    private EditText textInput;

    static String buildTextToSpeechUrl(String text) throws UnsupportedEncodingException {
        return TTS_ENDPOINT + URLEncoder.encode(normalizeSpeechText(text), "UTF-8");
    }

    static String normalizeSpeechText(String text) {
        if (text == null) {
            return "";
        }
        return text.trim();
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
        String speechText = normalizeSpeechText(text);
        if (speechText.length() == 0) {
            Toast.makeText(this, R.string.speech_input_required, Toast.LENGTH_SHORT).show();
            return;
        }
        if (speechText.length() > MAX_SPEECH_TEXT_LENGTH) {
            Toast.makeText(this, R.string.speech_input_too_long, Toast.LENGTH_SHORT).show();
            return;
        }

        releasePlayer();
        MediaPlayer nextPlayer = new MediaPlayer();
        nextPlayer.setAudioStreamType(AudioManager.STREAM_MUSIC);
        nextPlayer.setOnPreparedListener(new MediaPlayer.OnPreparedListener() {
            @Override
            public void onPrepared(MediaPlayer mediaPlayer) {
                try {
                    mediaPlayer.start();
                } catch (IllegalStateException e) {
                    handlePlaybackFailure(mediaPlayer, e);
                }
            }
        });
        nextPlayer.setOnErrorListener(new MediaPlayer.OnErrorListener() {
            @Override
            public boolean onError(MediaPlayer mediaPlayer, int what, int extra) {
                handlePlaybackFailure(mediaPlayer, null);
                return true;
            }
        });
        nextPlayer.setOnCompletionListener(new MediaPlayer.OnCompletionListener() {
            @Override
            public void onCompletion(MediaPlayer mediaPlayer) {
                handlePlaybackCompletion(mediaPlayer);
            }
        });

        try {
            nextPlayer.setDataSource(buildTextToSpeechUrl(speechText));
            player = nextPlayer;
            nextPlayer.prepareAsync();
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

    private void handlePlaybackCompletion(MediaPlayer completedPlayer) {
        if (completedPlayer != null) {
            completedPlayer.release();
            if (player == completedPlayer) {
                player = null;
            }
        }
    }

    private void handlePlaybackFailure(MediaPlayer failedPlayer, Exception error) {
        if (failedPlayer != null) {
            failedPlayer.release();
            if (player == failedPlayer) {
                player = null;
            }
        }

        Toast.makeText(this, R.string.speech_playback_failed, Toast.LENGTH_SHORT).show();
        if (error != null) {
            Log.w(TAG, "Unable to play TTS audio.", error);
        } else {
            Log.w(TAG, "Unable to play TTS audio.");
        }
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
