package hero.hero_sample;

import com.hero.HeroApplication;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

/**
 * Created by xincai on 17-4-5.
 */

public class HeroSampleApplication extends HeroApplication {
    public final static String HOME_ADDRESS = "http://localhost:3000";
    public final static String PATH = "__PATH";

    // please modify the init pages here
    public String getInitPages() {
        String server = getHomeAddress();
        return "[{url:'" + server + (PATH.startsWith("__") ? "" : PATH) + "/home.html'" + "}]";
    }

    @Override
    public void onCreate() {
        super.onCreate();
        try {
            JSONArray tabsArray = new JSONArray(getInitPages());
            JSONObject object = new JSONObject();
            object.put("tabs", tabsArray);
            getHeroApp().on(object);
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    @Override
    public String getHomeAddress() {
        return HOME_ADDRESS;
    }


    @Override
    public String getHttpReferer() {
        return "";
    }

}
