package garethpaul.com.androidspeaker;

import org.junit.Test;

import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNotEquals;
import static org.junit.Assert.assertTrue;

public class UtteranceOwnershipTest {
    private final UtteranceOwnership ownership = new UtteranceOwnership();

    @Test
    public void beginsDistinctOrderedUtterances() {
        String first = ownership.begin();
        String second = ownership.begin();

        assertTrue(first.endsWith("-1"));
        assertTrue(second.endsWith("-2"));
        assertNotEquals(first, second);
    }

    @Test
    public void clearsCurrentUtteranceExactlyOnce() {
        String current = ownership.begin();

        assertTrue(ownership.clear(current));
        assertFalse(ownership.clear(current));
    }

    @Test
    public void staleUtteranceCannotClearReplacement() {
        String stale = ownership.begin();
        String current = ownership.begin();

        assertFalse(ownership.clear(stale));
        assertTrue(ownership.clear(current));
    }

    @Test
    public void nullUtteranceCannotClearCurrentOwnership() {
        String current = ownership.begin();

        assertFalse(ownership.clear(null));
        assertTrue(ownership.clear(current));
    }

    @Test
    public void abandonmentInvalidatesCurrentUtterance() {
        String abandoned = ownership.begin();

        ownership.abandon();

        assertFalse(ownership.clear(abandoned));
    }

    @Test
    public void callbackAfterAbandonmentCannotClearFutureOwnership() {
        String abandoned = ownership.begin();
        ownership.abandon();
        String current = ownership.begin();

        assertFalse(ownership.clear(abandoned));
        assertTrue(ownership.clear(current));
    }
}
