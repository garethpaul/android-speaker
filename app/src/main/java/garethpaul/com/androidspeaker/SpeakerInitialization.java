package garethpaul.com.androidspeaker;

final class SpeakerInitialization {
    private boolean abandoned;
    private boolean completed;
    private boolean ready;

    synchronized void complete(boolean successful) {
        completed = true;
        ready = successful && !abandoned;
    }

    synchronized void abandon() {
        abandoned = true;
        ready = false;
    }

    synchronized boolean isReady() {
        return ready;
    }

    synchronized boolean shouldReleaseEngineAfterConstruction() {
        return completed && !ready;
    }
}
