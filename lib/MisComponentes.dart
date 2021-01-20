import 'package:flutter/material.dart';


/*-------------------------------------------------  PLANTILLA STATEFUL
class Formulario extends StatefulWidget{
  var json;
  Formulario({Key key,var Json}):super(key:key){
    print('Constructor Inicio clave: '+key.toString());
    this.json=Json;
  }
  @override
  FormularioState createState(){
    print("CreateState de Formulario");
    return new FormularioState();
  }
}
class FormularioState extends State<Formulario>{
  @override
  Widget build (BuildContext context){
    return Text(" Hola");
  }
}
 */

class Formulario extends StatefulWidget{
  var json;
  Formulario({Key key,var Json}):super(key:key){
  print('Constructor Inicio clave: '+key.toString());
  this.json=Json;
  }
  @override
  FormularioState createState(){
    print("CreateState de Formulario");
    return new FormularioState();
  }
}
class FormularioState extends State<Formulario>{
  @override
  Widget build (BuildContext context){
    return Text(" Hola");
  }
}