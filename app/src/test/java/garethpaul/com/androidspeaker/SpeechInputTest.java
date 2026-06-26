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

    @Test
    public void rejectsFormatAndCombiningMarkOnlyInput() {
        assertEquals("", SpeechInput.normalize("\u200b\u200d"));
        assertEquals("", SpeechInput.normalize("\u0301\u034f"));
    }

    @Test
    public void preservesVisibleUnicodeWithFormatAndCombiningMarks() {
        assertEquals("Cafe\u0301", SpeechInput.normalize("Cafe\u0301"));
        assertEquals(
                "\ud83d\udc69\u200d\ud83d\udcbb",
                SpeechInput.normalize("\ud83d\udc69\u200d\ud83d\udcbb"));
    }
}
