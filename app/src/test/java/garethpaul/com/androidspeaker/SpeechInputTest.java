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

    @Test
    public void collapsesUnicodeSpaceCharacters() {
        assertEquals("Hello world", SpeechInput.normalize("Hello\u00a0\u2007\u202fworld"));
    }

    @Test
    public void rejectsUnicodeSpaceOnlyInput() {
        assertEquals("", SpeechInput.normalize("\u00a0\u2007\u202f"));
    }
}
