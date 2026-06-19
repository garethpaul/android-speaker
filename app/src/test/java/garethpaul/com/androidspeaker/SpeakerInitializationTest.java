package garethpaul.com.androidspeaker;

import org.junit.Test;

import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;

public class SpeakerInitializationTest {
    @Test
    public void synchronousFailureIsRetainedUntilConstructedEngineCanBeReleased() {
        SpeakerInitialization initialization = new SpeakerInitialization();

        initialization.complete(false);

        assertTrue(initialization.shouldReleaseEngineAfterConstruction());
        assertFalse(initialization.isReady());
    }

    @Test
    public void successfulInitializationBecomesReady() {
        SpeakerInitialization initialization = new SpeakerInitialization();

        initialization.complete(true);

        assertFalse(initialization.shouldReleaseEngineAfterConstruction());
        assertTrue(initialization.isReady());
    }

    @Test
    public void abandonmentPreventsLateInitializationFromBecomingReady() {
        SpeakerInitialization initialization = new SpeakerInitialization();
        initialization.abandon();

        initialization.complete(true);

        assertTrue(initialization.shouldReleaseEngineAfterConstruction());
        assertFalse(initialization.isReady());
    }
}
