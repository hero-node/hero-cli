package hero.hero_sample;

import com.hero.HeroDrawerActivity;

/**
 * Created by xincai on 17-5-12.
 */

public class MainActivity extends HeroDrawerActivity {

    // this method will be called at the creating of the main activity
    // usually used to show a welcome page. After the main page is loaded, "finishLoading" will be sent
    @Override
    protected void startLoading() {

    }

    // this method will be called when "finishLoading" event is sent by the page
    // you can hide what you have shown in "startLoading" then you can see the main contents
    @Override
    protected void finishLoading() {

    }
}
