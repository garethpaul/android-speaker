package garethpaul.com.androidspeaker;

import android.app.Application;
import android.test.ApplicationTestCase;

/**
 * <a href="http://d.android.com/tools/testing/testing_android.html">Testing Fundamentals</a>
 */
public class ApplicationTest extends ApplicationTestCase<Application> {
    public ApplicationTest() {
        super(Application.class);
    }

    public void testApplicationCreatesSpeakerPackage() throws Exception {
        createApplication();

        assertNotNull(getApplication());
        assertEquals("garethpaul.com.androidspeaker", getApplication().getPackageName());
    }
}
