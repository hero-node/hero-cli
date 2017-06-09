import { Component } from 'hero-js';
import { Entry } from 'hero-cli/decorator';
import ui from './view';

@Entry()
@Component({
	view: ui
})
export class DecoratePage {


}
