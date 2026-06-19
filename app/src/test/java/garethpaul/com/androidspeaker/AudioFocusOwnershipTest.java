package garethpaul.com.androidspeaker;

import org.junit.Test;

import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;

public class AudioFocusOwnershipTest {
    private final AudioFocusOwnership ownership = new AudioFocusOwnership();

    @Test
    public void repeatedPlaybackReusesHeldFocus() {
        assertTrue(ownership.acquire());
        assertFalse(ownership.acquire());
    }

    @Test
    public void releaseIsOwnedExactlyOnce() {
        ownership.acquire();

        assertTrue(ownership.release());
        assertFalse(ownership.release());
        assertTrue(ownership.acquire());
    }
}
