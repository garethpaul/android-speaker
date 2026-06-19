package garethpaul.com.androidspeaker;

import org.junit.Test;

import static org.junit.Assert.assertEquals;

public class SpeechInputTest {
    @Test
    public void stripsControlCharactersBeforeSpeech() {
        assertEquals("Hello world", SpeechInput.normalize("Hello\u0000 world\n"));
    }

    @Test
    public void rejectsControlOnlyInput() {
        assertEquals("", SpeechInput.normalize("\u0000\n\t"));
    }
}
