package garethpaul.com.androidspeaker;

final class UtteranceOwnership {
    private long sequence;
    private String activeUtteranceId;

    synchronized String begin() {
        String utteranceId = "speaker-" + (++sequence);
        activeUtteranceId = utteranceId;
        return utteranceId;
    }

    synchronized boolean clear(String utteranceId) {
        if (utteranceId == null || !utteranceId.equals(activeUtteranceId)) {
            return false;
        }
        activeUtteranceId = null;
        return true;
    }

    synchronized void abandon() {
        activeUtteranceId = null;
    }
}
