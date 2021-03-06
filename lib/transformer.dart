library golang.transformer;

import 'package:barback/barback.dart';
import 'dart:async';
import 'package:html5lib/parser.dart' show parse;
import 'package:html5lib/dom.dart';
import 'dart:collection';


class GolangTransformer extends Transformer { 

  final BarbackSettings settings; 
  
  String host;
  
  GolangTransformer() : settings = null; 
  
  GolangTransformer.asPlugin(this.settings){
    var args = settings.configuration;
    this.host = args['host'];
    if(this.host == null){
      print("You will need to add a 'host' variable in your project's pubspec.yaml file that I will strip out.\n");
    }
  }
  
  
  Future<bool> isPrimary(Asset input) {  
    return new Future.value(input.id.extension == '.html'); 
  } 

  Future apply(Transform transform) { 
    var input = transform.primaryInput;
    var id = input.id;
    return transform.
        readInputAsString(id).
        then((content) {
          Document document = parse(content);
          List<Element> forms = document.queryAll('form');
          if(forms.length > 0){
            for(Element tag in forms){
              Element newTag = tag;
              LinkedHashMap<dynamic,String> attributes = tag.attributes;
              if(attributes.containsKey('action')){
                String attribute = attributes['action'];
                if(this.host != null && attribute.startsWith(this.host)){
                  newTag.attributes['action'] = attribute.substring(this.host.length);  
                }
              }
              tag.replaceWith(newTag);
            }
          }
        transform.addOutput(new Asset.fromString(id, document.outerHtml)); 
    }); 
  } 
} 