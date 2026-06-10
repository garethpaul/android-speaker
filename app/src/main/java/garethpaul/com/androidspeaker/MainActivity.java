package garethpaul.com.androidspeaker;

import android.app.Activity;
import android.os.Bundle;
import android.speech.tts.TextToSpeech;
import android.speech.tts.UtteranceProgressListener;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Toast;

import java.util.Locale;


public class MainActivity extends Activity implements TextToSpeech.OnInitListener {
    private static final String TAG = "androidspeaker";
    private static final int MAX_SPEECH_TEXT_LENGTH = 200;

    private Button playButton;
    private EditText textInput;
    private TextToSpeech textToSpeech;
    private boolean textToSpeechReady;
    private long utteranceSequence;
    private volatile String activeUtteranceId;

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
        playButton = (Button) findViewById(R.id.button);

        if (textInput == null || playButton == null) {
            Log.e(TAG, "Speaker controls are unavailable.");
            finish();
            return;
        }

        playButton.setEnabled(false);
        playButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                playText(String.valueOf(textInput.getText()));
            }
        });

        textToSpeech = new TextToSpeech(getApplicationContext(), this);
    }

    @Override
    public void onInit(int status) {
        final TextToSpeech engine = textToSpeech;
        if (status != TextToSpeech.SUCCESS || engine == null) {
            handleEngineInitializationFailure();
            return;
        }

        int languageStatus = engine.setLanguage(Locale.US);
        if (languageStatus == TextToSpeech.LANG_MISSING_DATA
                || languageStatus == TextToSpeech.LANG_NOT_SUPPORTED) {
            handleEngineInitializationFailure();
            return;
        }

        engine.setOnUtteranceProgressListener(new UtteranceProgressListener() {
            @Override
            public void onStart(String utteranceId) {
            }

            @Override
            public void onDone(String utteranceId) {
                clearActiveUtterance(utteranceId);
            }

            @Override
            public void onError(String utteranceId) {
                if (!clearActiveUtterance(utteranceId)) {
                    return;
                }

                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        showToast(R.string.speech_playback_failed);
                    }
                });
            }
        });

        textToSpeechReady = true;
        if (!isFinishing() && !isDestroyed()) {
            playButton.setEnabled(true);
        }
    }

    private void playText(String text) {
        String speechText = normalizeSpeechText(text);
        if (speechText.length() == 0) {
            showToast(R.string.speech_input_required);
            return;
        }
        if (speechText.length() > MAX_SPEECH_TEXT_LENGTH) {
            showToast(R.string.speech_input_too_long);
            return;
        }

        TextToSpeech engine = textToSpeech;
        if (!textToSpeechReady || engine == null) {
            showToast(R.string.speech_engine_unavailable);
            return;
        }

        String utteranceId = "speaker-" + (++utteranceSequence);
        activeUtteranceId = utteranceId;
        int result = engine.speak(speechText, TextToSpeech.QUEUE_FLUSH, null, utteranceId);
        if (result == TextToSpeech.ERROR) {
            clearActiveUtterance(utteranceId);
            showToast(R.string.speech_playback_failed);
        }
    }

    private void handleEngineInitializationFailure() {
        textToSpeechReady = false;
        if (playButton != null) {
            playButton.setEnabled(false);
        }
        Log.w(TAG, "Text-to-speech engine is unavailable.");
        showToast(R.string.speech_engine_unavailable);
    }

    private boolean clearActiveUtterance(String utteranceId) {
        if (utteranceId == null || !utteranceId.equals(activeUtteranceId)) {
            return false;
        }
        activeUtteranceId = null;
        return true;
    }

    private void showToast(int messageId) {
        if (!isFinishing() && !isDestroyed()) {
            Toast.makeText(this, messageId, Toast.LENGTH_SHORT).show();
        }
    }

    @Override
    protected void onPause() {
        activeUtteranceId = null;
        if (textToSpeech != null) {
            textToSpeech.stop();
        }
        super.onPause();
    }

    @Override
    protected void onDestroy() {
        textToSpeechReady = false;
        activeUtteranceId = null;
        if (textToSpeech != null) {
            textToSpeech.stop();
            textToSpeech.shutdown();
            textToSpeech = null;
        }
        super.onDestroy();
    }
}
