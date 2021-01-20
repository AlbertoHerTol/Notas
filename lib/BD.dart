import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:date_format/date_format.dart';


class DataBase{

  //Usuario
  UserCredential _userCredential;
  String _idUser;
  var firebaseUser = null;
  //Notas
  String doc;
  Map<String, dynamic> JsonDoc;
  List<Nota> arrayNotas;
  //Firebase
  FirebaseFirestore BD = null;
  CollectionReference pinesColection = null; // objeto firestore



  DataBase(UserCredential user){

    print('Constructor DataBase' );
    //Usuario
    this._userCredential=user;
    //firebaseUser =  FirebaseAuth.instance.currentUser;
    _idUser = user.additionalUserInfo.profile["aud"].toString();
    //Firebase
    // Iniciamos
    BD = FirebaseFirestore.instance;
    pinesColection = BD.collection("Usuarios");
    if (BD==null ) print ("NO EXISTE LA FIRESTORE \n***********************\n");
    if (pinesColection==null ) print ("NO EXISTE LA COLLECION \n***********************\n");

    getDbData().then((x){
      print('Entrando en then() getDbData');
      doc=x;

      print('Entro en decode');
      JsonDoc=jsonDecode(doc);
      arrayNotas=DecodeNotas(JsonDoc);
      //kInicio.currentState.repaint(objJson);
    });

  }






  Future<String> getDbData() async{
    var documento=null;
    print("\n\n-----------------------------     GET DATA");
    while (documento==null) {
      /*
      pinesColection.get().then((QuerySnapshot querySnapshot) =>
      {querySnapshot.docs.forEach((doc) {
        print("==========> " + doc.toString());

        var d = doc.data();
        print("DOCUMENTO: " + d.toString());
        if (d["idUser"].toString() == _idUser) {
          print("ENCONTRADO " + _idUser);
          documento = d;
        }
      })

      });*/
      pinesColection.doc(_idUser).get().then((value){
        var d=value.data();
        print(value.data());
        print("ENCONTRADO " + _idUser);
        documento = d;
      });


      //Si no existe
      if (documento == null) {

        print("\n\n-----------------------------     CREANDO DOCUMENTO PARA EL USUARIO " +_idUser);
        /*
        Future<void> addUser() {
          return pinesColection.doc('ABC123').set({
            "idUser": _idUser,
            "Contador": 0
          }).then((value) => print("User Added")).catchError((error) => print("Failed to add user: $error"));
        }*/

        pinesColection.doc(_idUser/*firebaseUser.uid*/).set({
          "idUser": _idUser,
          "Contador": 0
        }).then((_) {
          print("success!");
        });
      }
    }
    return documento.toString();
  }

  void actualizarUpload(List<Nota> arrayNot){
    Map<String, dynamic>  jSon = EncodeNotas(arrayNot);
    if (jSon["Notas"]!=null && jSon["Contador"]!=null){
      jSon["Contador"] = jSon["Notas"].length;
    }
    print("\n\n-----------------------------     Upload");
    pinesColection.doc(_idUser).set(jSon).then((_) {
      print("success!");
    });
  }

  Future<String> actualizarDowload() async{
    var documento=null;
    print("\n\n-----------------------------     Download");
    pinesColection.get().then((QuerySnapshot querySnapshot) => {
      querySnapshot.docs.forEach((doc) {
        print("==========> " + doc.toString());

        var d = doc.data();
        print("DOCUMENTO: " + d.toString());
        if (d["idUser"].toString() == _idUser) {
          print("ENCONTRADO " + _idUser);
          documento = d;
        }
      })
    });
    return documento.toString();
  }

  void escuchar() async{
    print("\nEscuchando..................................................................\n");

    pinesColection.doc("_idUser").snapshots().listen((event){
      print ("HEY!!!"+ event.toString()+""+event.id);
      print(event.data().toString());
      actualizarDowload().then((x){
        print('Entrando en then() actualizarDowload');
        doc=x;
        print('Entro en decode');
        JsonDoc=jsonDecode(doc);
        arrayNotas=DecodeNotas(JsonDoc);
      });
    });
  }

  List<Nota> DecodeNotas(Map<String, dynamic> jSon){
    List<Nota> arrayNotitas;
    for (int i=0; i< jSon["Contador"]; i++){
      arrayNotitas.add(new Nota(
          jSon["Notas"][i]["Titulo"],//Titulo
          jSon["Notas"][i]["Texto"],
          jSon["Notas"][i]["Categoria"],
          jSon["Notas"][i]["Fecha"],
          null,
          jSon["Notas"][i]["Prioridad"]
      ));
    }
    return arrayNotitas;
  }

  Map<String, dynamic> EncodeNotas( List<Nota> arrayNot){

    Map<String, dynamic> map;
    String s = "{Notas: [";
    for (int i=0; i< arrayNot.length; i++){
      s+="{Categoria: "+arrayNot[i].categoria+", Fecha: "+arrayNot[i].fechaString+", Prioridad: "+arrayNot[i].prioridad.toString()+", Texto: "+arrayNot[i].texto+", Titulo: "+arrayNot[i].titulo+"}";
      if (i<(arrayNot.length)-1)  s+= ", ";
    }
    s += "], Contador: "+arrayNot.length.toString()+"}";
    map=jsonDecode(s);
    return map;
  }

}

class Nota {
  String titulo;
  String texto;
  String categoria;
  IconData icono;
  String fechaString;
  DateTime fecha;
  int prioridad;

  Nota(String titulo, String texto, String categoria, String fechaStr, DateTime fechaDateTime, int prioridad) {
    this.texto = texto;
    this.titulo = titulo;
    this.categoria = categoria;

    this.prioridad = prioridad;

    if (fechaStr == null){
      this.fecha = fechaDateTime;
      this.fechaString =convertStringFromDate(fechaDateTime);
    }
    if (fechaDateTime == null){
      this.fechaString = fechaStr;
      this.fecha =convertDateFromString(fechaStr);
    }

    this.icono = putIcon(this.categoria);
  }

  IconData putIcon(String category){
    IconData i;

    switch(category){
      case "Deporte": i=Icons.pool; break;
      case "Comida": i=Icons.fastfood; break;
      case "Estudios": i=Icons.school; break;
      case "Películas": i=Icons.movie; break;
      case "Diversión": i=Icons.attach_money; break;
      case "Gimnasio": i=Icons.fitness_center; break;
      case "Viajes": i=Icons.local_airport; break;
      default: break;
    }
    return i;

  }

  String convertStringFromDate(DateTime date) {
    String s=(formatDate(date, [yyyy, '-', mm, '-', dd, ' ', hh, ':', nn, ':', ss, ' ', am]));
    print(s);
    return s;

  }

  DateTime convertDateFromString(String strDate){
    DateTime todayDate = DateTime.parse(strDate);
    print(todayDate);
    print(formatDate(todayDate, [yyyy, '/', mm, '/', dd, ' ', hh, ':', nn, ':', ss, ' ', am]));
    return todayDate;
  }


}