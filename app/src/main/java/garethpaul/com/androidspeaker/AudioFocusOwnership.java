package garethpaul.com.androidspeaker;

final class AudioFocusOwnership {
    private boolean held;

    synchronized boolean acquire() {
        if (held) {
            return false;
        }
        held = true;
        return true;
    }

    synchronized boolean release() {
        if (!held) {
            return false;
        }
        held = false;
        return true;
    }
}
