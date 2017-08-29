import { Component, Hero } from '@dr/hero-js'
import { PATH as path } from '../constant/index'

setTimeout(() => Hero.out({ global: { key: 'finishLoading' } }), 10)

@Component({
  view: {
    version: 0,
    backgroundColor: 'f5f5f5',
    nav: {
      title: 'Hero-Mobile'
    },
    views:
      [
        {
          class: 'UIView',
          frame: { w: '1x', h: '1x' },
          backgroundColor: 'ffffff'
        },
        {
          class: 'HeroLabel',
          name: 'cash',
          alignment: 'center',
          frame: { w: '1x', y: '9', h: '27' },
          textColor: '333333',
          size: 18,
          text: 'Hero-Mobile'
        },
        {
          class: 'UIView',
          frame: { w: '1x', y: '40', h: '1' },
          backgroundColor: 'e4e4e4'
        },
        {
          class: 'HeroLabel',
          frame: { x: '43', w: '200', y: '60', h: '15' },
          textColor: '00bc8d',
          size: 14,
          text: 'What\'s Hero-Mobile?'
        },
        {
          class: 'HeroLabel',
          frame: { x: '25', r: '25', y: '82', h: '34' },
          textColor: '666666',
          size: 12,
          numberOfLines: 2,
          text: 'Hero-Mobile lets developers build beautiful and interactive mobile apps using HTML5 and JavaScript.'
        },
        {
          class: 'HeroLabel',
          frame: { x: '43', w: '200', y: '128', h: '15' },
          textColor: '00bc8d',
          size: 14,
          text: 'Why Hero-Mobile'
        },
        {
          class: 'HeroLabel',
          frame: { x: '25', r: '25', y: '150', h: '34' },
          textColor: '666666',
          size: 12,
          numberOfLines: 2,
          text: 'Across All Platforms: Reuse your code and abilities to build apps for any deployment target.'
        },
        {
          class: 'HeroLabel',
          frame: { x: '25', r: '25', y: '185', h: '34' },
          textColor: '666666',
          size: 12,
          numberOfLines: 2,
          text: 'Speed & Performance: Using the JavaScript without 3rd libraries.'
        },
        {
          class: 'HeroLabel',
          frame: { x: '25', r: '25', y: '220', h: '34' },
          textColor: '666666',
          size: 12,
          numberOfLines: 2,
          text: 'Incredible Tooling: Using tools/plugins for JavaScript whatever you like.'
        },
        {
          class: 'HeroLabel',
          frame: { x: '43', w: '200', y: '266', h: '15' },
          textColor: '00bc8d',
          size: 14,
          text: 'How to use Hero-Mobile'
        },
        {
          class: 'HeroLabel',
          frame: { x: '25', r: '25', y: '288', h: '54' },
          textColor: '666666',
          size: 12,
          numberOfLines: 2,
          text: 'Hero-Mobile focus on application logic, you can using built-in components or your own components. For more details, see https://hero-mobile.github.io/hero-js'
        },
        {
          class: 'HeroImageView',
          frame: { x: '20', w: '18', y: '57', h: '18' },
          image: path + '/images/icon_1.png'
        },
        {
          class: 'HeroImageView',
          frame: { x: '20', w: '18', y: '125', h: '18' },
          image: path + '/images/icon_2.png'
        },
        {
          class: 'HeroImageView',
          frame: { x: '20', w: '18', y: '263', h: '18' },
          image: path + '/images/icon_3.png'
        }
      ]
  }
})
export class DecoratePage {}
