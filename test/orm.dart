import '../entity/hardware.e.dart';

import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:html5lib/dom.dart';
import 'package:html5lib/dom_parsing.dart';
import 'package:html5lib/parser.dart';
import 'package:orm/orm.dart';
import 'package:sqljocky/sqljocky.dart';
import 'package:unittest/unittest.dart';

const String UNKNOWN = 'Unknown';

void main () {
  /*test('orm.dart', () {
    RegExp regexManifacturerName = new RegExp (r'\b(\w+)\b (.*)', caseSensitive: true, multiLine: false);
    Directory dir = new Directory('/home/andrea/mirror/www.techpowerup.com/gpudb');
    dir.listSync(recursive: false, followLinks: false).forEach((entity) {
      if (entity is Directory) {
        var files = entity.listSync(recursive: false, followLinks: false);
        if (files.isNotEmpty) {
          File file = files.first;
          Document d = parse(file.readAsStringSync());
          //Getting article
          Element article = d.querySelectorAll('article').firstWhere((test) 
              => 'content gpudb' == test.attributes['class'], orElse: ()
              => null);
          if (null != article) {
            String name, manifacturer;
            //Getting full gpu name
            Element gpuName = article.querySelectorAll('h1').firstWhere((test) 
                => 'gpuname' ==  test.attributes['class'], orElse: () => null);
            if (null == gpuName) {
              name = manifacturer = UNKNOWN;
            } else {
              Match m = regexManifacturerName.firstMatch(gpuName.innerHtml);
              if (null == m) {
                name = manifacturer = UNKNOWN;
              } else {
                manifacturer = m[1];
                name = m[2];
              }
            }
            Element cardphoto = article.querySelectorAll('img').firstWhere((test) 
                            => 'cardphoto' ==  test.attributes['class'], 
                            orElse: () => null);
            if (null != cardphoto) {
              List<int> data = 
                  new File('/home/andrea/mirror/www.techpowerup.com/gpudb/${
                cardphoto.attributes['src'].replaceFirst('../', '')}')
                .readAsBytesSync();
              String base64 = CryptoUtils.bytesToBase64(data, urlSafe: true, 
                  addLineSeparator: false);
              
            }
            Element gpuphoto = article.querySelectorAll('img').firstWhere((test) 
                            => 'gpuphoto' ==  test.attributes['class'], 
                            orElse: () => null);
          }
        }
      }
    });
  });*/
    ConnectionPool pool = new ConnectionPool(db: 'orm', host: '127.0.0.1', user: 'root', password: 'iU4hrS16f5.93');
    Orm orm = new Orm(new MySqlDataStore(pool));
    Hardware h = new Hardware(id: 0);
    orm.datastore.get(h);
    h.productor = 'ciao';
    orm.datastore.close();
}