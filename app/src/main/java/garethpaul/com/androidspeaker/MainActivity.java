package garethpaul.com.androidspeaker;

import android.app.Activity;
import android.content.Context;
import android.media.AudioAttributes;
import android.media.AudioManager;
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
    private AudioManager audioManager;
    private final SpeakerInitialization speakerInitialization = new SpeakerInitialization();
    private final UtteranceOwnership utteranceOwnership = new UtteranceOwnership();
    private final AudioFocusOwnership audioFocusOwnership = new AudioFocusOwnership();
    private final AudioManager.OnAudioFocusChangeListener audioFocusChangeListener =
            new AudioManager.OnAudioFocusChangeListener() {
                @Override
                public void onAudioFocusChange(int focusChange) {
                    if (focusChange < 0) {
                        utteranceOwnership.abandon();
                        if (textToSpeech != null) {
                            textToSpeech.stop();
                        }
                        releaseAudioFocus();
                    }
                }
            };

    static String normalizeSpeechText(String text) {
        return SpeechInput.normalize(text);
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

        audioManager = (AudioManager) getSystemService(Context.AUDIO_SERVICE);
        TextToSpeech engine = new TextToSpeech(getApplicationContext(), this);
        textToSpeech = engine;
        if (speakerInitialization.shouldReleaseEngineAfterConstruction()) {
            releaseEngine(engine);
            textToSpeech = null;
        }
    }

    @Override
    public void onInit(int status) {
        final TextToSpeech engine = textToSpeech;
        if (status != TextToSpeech.SUCCESS || engine == null) {
            speakerInitialization.complete(false);
            handleEngineInitializationFailure();
            return;
        }

        int languageStatus = engine.setLanguage(Locale.US);
        if (languageStatus == TextToSpeech.LANG_MISSING_DATA
                || languageStatus == TextToSpeech.LANG_NOT_SUPPORTED) {
            speakerInitialization.complete(false);
            handleEngineInitializationFailure();
            return;
        }

        int audioStatus = engine.setAudioAttributes(new AudioAttributes.Builder()
                .setUsage(AudioAttributes.USAGE_MEDIA)
                .setContentType(AudioAttributes.CONTENT_TYPE_SPEECH)
                .build());
        if (audioStatus == TextToSpeech.ERROR) {
            speakerInitialization.complete(false);
            handleEngineInitializationFailure();
            return;
        }

        int listenerStatus = engine.setOnUtteranceProgressListener(
                new UtteranceProgressListener() {
                    @Override
                    public void onStart(String utteranceId) {
                    }

                    @Override
                    public void onDone(String utteranceId) {
                        if (utteranceOwnership.clear(utteranceId)) {
                            releaseAudioFocus();
                        }
                    }

                    @Override
                    public void onError(final String utteranceId) {
                        runOnUiThread(new Runnable() {
                            @Override
                            public void run() {
                                if (utteranceOwnership.clear(utteranceId)) {
                                    releaseAudioFocus();
                                    showToast(R.string.speech_playback_failed);
                                }
                            }
                        });
                    }
                });
        if (listenerStatus == TextToSpeech.ERROR) {
            speakerInitialization.complete(false);
            handleEngineInitializationFailure();
            return;
        }

        speakerInitialization.complete(true);
        if (!speakerInitialization.isReady()) {
            handleEngineInitializationFailure();
            return;
        }
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
        if (!speakerInitialization.isReady() || engine == null) {
            showToast(R.string.speech_engine_unavailable);
            return;
        }

        if (!requestAudioFocus()) {
            showToast(R.string.speech_playback_failed);
            return;
        }

        String utteranceId = utteranceOwnership.begin();
        int result = engine.speak(speechText, TextToSpeech.QUEUE_FLUSH, null, utteranceId);
        if (result == TextToSpeech.ERROR) {
            utteranceOwnership.clear(utteranceId);
            releaseAudioFocus();
            showToast(R.string.speech_playback_failed);
        }
    }

    private void handleEngineInitializationFailure() {
        speakerInitialization.complete(false);
        TextToSpeech engine = textToSpeech;
        textToSpeech = null;
        releaseEngine(engine);
        releaseAudioFocus();
        if (playButton != null) {
            playButton.setEnabled(false);
        }
        Log.w(TAG, "Text-to-speech engine is unavailable.");
        showToast(R.string.speech_engine_unavailable);
    }

    private boolean requestAudioFocus() {
        if (!audioFocusOwnership.acquire()) {
            return true;
        }
        if (audioManager == null || audioManager.requestAudioFocus(
                audioFocusChangeListener,
                AudioManager.STREAM_MUSIC,
                AudioManager.AUDIOFOCUS_GAIN_TRANSIENT) != AudioManager.AUDIOFOCUS_REQUEST_GRANTED) {
            audioFocusOwnership.release();
            return false;
        }
        return true;
    }

    private void releaseAudioFocus() {
        if (audioFocusOwnership.release() && audioManager != null) {
            audioManager.abandonAudioFocus(audioFocusChangeListener);
        }
    }

    private void releaseEngine(TextToSpeech engine) {
        if (engine != null) {
            engine.stop();
            engine.shutdown();
        }
    }

    private void showToast(int messageId) {
        if (!isFinishing() && !isDestroyed()) {
            Toast.makeText(this, messageId, Toast.LENGTH_SHORT).show();
        }
    }

    @Override
    protected void onPause() {
        utteranceOwnership.abandon();
        releaseAudioFocus();
        if (textToSpeech != null) {
            textToSpeech.stop();
        }
        super.onPause();
    }

    @Override
    protected void onDestroy() {
        speakerInitialization.abandon();
        utteranceOwnership.abandon();
        releaseAudioFocus();
        releaseEngine(textToSpeech);
        textToSpeech = null;
        super.onDestroy();
    }
}
