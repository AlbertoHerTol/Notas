import 'package:flutter/material.dart';
import 'package:dropdown_formfield/dropdown_formfield.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'BD.dart';

/*
****************Codigo que podemos meter*************
* var now = new DateTime.now();

* var formatter = new DateFormat("yyyy-MM-dd");

* String formattedDate = formatter.format(now);

* print(formattedDate); // 2016-01-25
*****************************************************
*/

/*-----------------------------------------------------------------*/
/*-------------------Estas hacerlas locales------------------------*/
/*-----------------------------------------------------------------/
int ocultar = 0; //luego meter lo de keys y esas mierdad
var notas = [
  new Nota("titulo", "texto", Icons.directions_railway, new DateTime.now(), 1)
];
/-----------------------------------------------------------------*/
/*-----------------------------------------------------------------*/

/*void llenarArray() {
  for (int i = 0; i < 6; i++) {
    notas.add(new Nota(
        "Fernando",
        "texto mas largo que yokese lista de la compra una movie",
        Icons.directions_railway,
        new DateTime.now(),
        2));
    notas.add(new Nota(
        "Costa",
        "Eramos pbres solo habia la play dos ahora gorrita   laker las jordan nuevas ",
        Icons.ac_unit,
        new DateTime.now(),
        0));
  }
}*/

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp() {
    print("Costructor del State MyApp");
    //llenarArray();
    //print(notas.length);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => ListaNotas(),
        '/second': (context) => AgregarNota(null, null),
        '/third': (context) => VisualizarNota(null, null), //ver si esto se puede quitar
        '/fourth': (context) => Configuracion(null),//ver si esto se puede quitar
      },
    );
  }
}

class ListaNotas extends StatefulWidget {
  //es el layout de lista de notas
  @override
  _ListaNotasState createState() => _ListaNotasState();
}

class _ListaNotasState extends State<ListaNotas> {
  DataBase BD;
  UserCredential user;
  String _linkImageProfile = "https://definicion.de/wp-content/uploads/2019/06/perfildeusuario.jpg";
  String _nameUser = "Anónimo";
  String mostrar="Inicio";

  @override
  void initState() {
    print("Init firebase");
    super.initState();
    Firebase.initializeApp().whenComplete(() {
      print("completed");

      signInWithGoogle().then((x){
        setState(() {
          user = x;
          print("EL USUARIO --> "+user.toString());
          _linkImageProfile = user.additionalUserInfo.profile["picture"].toString();
          _nameUser  = user.additionalUserInfo.profile["name"].toString();
          BD= new DataBase(user);
          //_idUser = user.additionalUserInfo.profile["aud"].toString();
        });
      });


    });
  }

  Future<UserCredential> signInWithGoogle() async {
    print("\n\n-----------------------------     ENTRANDO EN SignInWithGoogle");
    //login
    final GoogleSignIn _googleSignIn = GoogleSignIn();
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    print("?");
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    print("?");
    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    var user = await _auth.signInWithCredential(credential);
    print("\n\n-----------------------------     signed in " + user.toString());
    return user;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      //Sirve para mover a la screen anterior
        onWillPop: () {
          Navigator.pop(context);
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text('Lista de notas'),
            backgroundColor: Colors.pink,
            leading: IconButton(
              tooltip: 'Ajustes para eliminar notas',
              icon: Icon(Icons.settings),
              onPressed: () {
                //debugPrint("Aqui meter los ajustes como un buen G");
                // moveToLastScreen();
                //Aqui meter pantalla para hacer los ajustes
                //Para lo de drawer
                //debugPrint('Ajustes, rellenarlo');
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return Configuracion(BD);
                }));
              },
            ),
            actions: [
              IconButton(
                tooltip: 'Filtros',
                icon: Icon(Icons.assignment),
                onPressed: () {
                  showAlertDialogFiltro(context);
                },
              ),
              IconButton(
                tooltip: 'Compartir nota, muy fueraaaa la verdad',
                icon: Icon(Icons.share),
                onPressed: () {},
              )
            ], // esto es para poner un boton para poder ir para atras
          ),
          body: _myListView(context),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return AgregarNota(null, BD);
              }));
            },
            tooltip: 'Añadir Nota',
            child: Icon(Icons.add),
          ),
        ));
    //_myListView(context);
  }


  Widget _myListView(BuildContext context) {
    return ListView.builder(
      itemCount: BD.arrayNotas.length,
      itemBuilder: (context, index) {
        return Card(
          child: ListTile(
            leading: Icon(BD.arrayNotas[index].icono),
            title: Text(BD.arrayNotas[index].titulo),
            onTap: () {
              // <-- onTap

              debugPrint('En mi zona');
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return VisualizarNota(BD.arrayNotas[index], BD);
              }));
            },
            onLongPress: () {
              //                            <-- onLongPress
              /// se podria quitar el set state
              showAlertDialog(context, index);
            },
          ),
        );
      },
    );
  }

  showAlertDialog(BuildContext context, int index) {
    // set up the buttons

    Widget continueButton = FlatButton(
      child: Text("Borrar"),
      onPressed: () {
        //                            <-- onLongPress
        setState(() {
          BD.arrayNotas.removeAt(index);
          Navigator.of(context).pop();
        });
      },
    );
    Widget cancelButton = FlatButton(
      child: Text("no no"),
      onPressed: () {
        //                           <-- onLongPress
        Navigator.of(context).pop();
        // notas.removeAt(index);
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Filtro de Notas"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  showAlertDialogFiltro(BuildContext context) {
    // set up the buttons

    Widget flitroTitulo = FlatButton(
      child: Text("Título"),
      onPressed: () {
        Nota aux;
        for (int i = 0; i < BD.arrayNotas.length - 1; i++) {
          for (int j = 0; j < BD.arrayNotas.length - i - 1; j++) {
            if ( BD.arrayNotas[j + 1].titulo.codeUnitAt(0) <  BD.arrayNotas[j].titulo.codeUnitAt(0)) { //por codigo ascii para caracter
              aux = BD.arrayNotas[j + 1];
              BD.arrayNotas[j + 1] = BD.arrayNotas[j];
              BD.arrayNotas[j] = aux;
            }
          }
        }
        Navigator.popAndPushNamed(context, '/');
      },
    );
    Widget filtroOtro = FlatButton(//funciona
      child: Text("Prioridad"),
      onPressed: () {
        // llenarArray();
        Nota aux;
        for (int i = 0; i < BD.arrayNotas.length - 1; i++) {
          for (int j = 0; j < BD.arrayNotas.length - i - 1; j++) {
            if (  BD.arrayNotas[j + 1].prioridad < BD.arrayNotas[j].prioridad ){
              aux = BD.arrayNotas[j + 1];
              BD.arrayNotas[j + 1] = BD.arrayNotas[j];
              BD.arrayNotas[j] = aux;
            }
          }
        }
        Navigator.popAndPushNamed(context, '/');

        //                           <-- onLongPress
        // Navigator.of(context).pop();
        // notas.removeAt(index);
      },
    );
    Widget filtroOtro2 = FlatButton(
      child: Text("Fecha"),
      onPressed: () {
        Nota aux;
        for (int i = 0; i < BD.arrayNotas.length - 1; i++) {
          for (int j = 0; j < BD.arrayNotas.length - i - 1; j++) {
            if (  BD.arrayNotas[j + 1].fecha.isAfter(BD.arrayNotas[j].fecha) ){
              aux = BD.arrayNotas[j + 1];
              BD.arrayNotas[j + 1] = BD.arrayNotas[j];
              BD.arrayNotas[j] = aux;
            }
          }
        }
        Navigator.popAndPushNamed(context, '/');
        //                           <-- onLongPress
        //Navigator.of(context).pop();
        // notas.removeAt(index);
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Filtros Para Notas"),
      actions: [
        flitroTitulo,
        filtroOtro,
        filtroOtro2,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}


class AgregarNota extends StatefulWidget {
  DataBase BD;
  Nota nota ;
  @override
  _AgregarNotaState createState() => _AgregarNotaState(nota, BD);

  AgregarNota(Nota, DataBase bd){this.nota = Nota;this.BD=bd;}

}
class _AgregarNotaState extends State<AgregarNota> {
  DataBase BD;
  Nota nota;
  final String ruta= '/';
  final _claveFormulario = GlobalKey<FormState>();
  final TextEditingController _titulo = TextEditingController();
  final TextEditingController _texto = TextEditingController();

  IconData _icono ; //quitar null y ver si va bien
  String _categoria;
  int _prioridad, posicion_nota;
  DateTime _fecha;
  bool modificar = true;
  String AppBar_title="Agregar Nota";

  _AgregarNotaState(nota, DataBase bd){
    this.nota=nota;
    this.BD = bd;
    if(nota!=null){
      _icono=this.nota.icono;
      _categoria=this.nota.categoria;
      _prioridad=this.nota.prioridad;
      _titulo.text=this.nota.titulo;
      _texto.text=this.nota.texto;
      _fecha = this.nota.fecha;
      posicion_nota=BD.arrayNotas.indexOf(nota);
      AppBar_title="Modificar Nota";
    }
  }

//  _AgregarNotaState({Key key}) : super();


  @override
  Widget build(BuildContext context) {
    void showAlertDialog(String title, String message, bool exito) {
      Widget continuar = FlatButton(
        child: Text("Continuar"),
        onPressed: () {
          if (exito) {
            moveToLastScreen();
          } else {
            Navigator.of(context).pop();
          }
          setState(() {});
        },
      );
      AlertDialog alertDialog = AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [continuar],
      );
      showDialog(context: context, builder: (_) => alertDialog);
    }
    // notas.add(new Nota(_titulo.text, _texto.text, _icono,
    //                           new DateTime.now(), _prioridad));


    return WillPopScope(
      //esto es lo que hace que cuando vaya pa atras no se joda
        onWillPop: () {
          moveToLastScreen();
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(AppBar_title),
          ),
          body: Form(
            key: _claveFormulario,
            child: ListView(shrinkWrap: true, children: <Widget>[
              Padding(
                padding: EdgeInsets.all(16.0),
                child: TextFormField(
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Escribe el titulo';
                    }
                    return null;
                  },
                  controller: _titulo,
                  decoration: InputDecoration(
                    hintText: 'Escribe el titulo',
                    labelText: "Titulo",
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16.0),
                child: TextFormField(
                  maxLines: 5,
                  minLines: 3,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Escribe el texto de la nota';
                    }
                    return null;
                  },
                  controller: _texto,
                  decoration: InputDecoration(
                    hintText: 'Escribe el texto de la nota',
                    labelText: "Texto de la Nota",
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.all(16.0),
                child: DropDownFormField(
                  titleText: 'Icono de Nota',
                  hintText: 'Elija el icono de la nota',
                  value: _icono,
                  onSaved: (value) {
                    setState(() {
                      if(_icono!=null){_icono=null;}
                      _icono  = value;
                      _categoria = putCategory(_icono.toString());
                    });
                  },
                  onChanged: (value) {
                    setState(() {
                      if(_icono!=null){_icono=null;}
                      _icono = value;
                    });
                  },
                  dataSource: [
                    {
                      "display": "Deporte",
                      "value": Icons.pool,
                    },
                    {
                      "display": "Comida",
                      "value": Icons.fastfood,
                    },
                    {
                      "display": "Colegio/Universidad",
                      "value": Icons.school,
                    },
                    {
                      "display": "Peliculas",
                      "value": Icons.movie,
                    },
                    {
                      "display": "Diversion",
                      "value": Icons.attach_money,
                    },
                    {
                      "display": "Gimnasio",
                      "value": Icons.fitness_center,
                    },
                    {
                      "display": "Viajes",
                      "value": Icons.local_airport,
                    }, //aqui se podrian añadir mas
                  ],
                  textField: 'display',
                  valueField: 'value',
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16.0),
                child: DropDownFormField(
                  titleText: 'Prioridad de la nota',
                  hintText: 'Elija la prioridad de la nota',
                  value: _prioridad,
                  onSaved: (value) {
                    setState(() {
                      _prioridad = value;
                    });
                  },
                  onChanged: (value) {
                    setState(() {
                      _prioridad = value;
                    });
                  },
                  dataSource: [
                    {
                      "display": "Alta",
                      "value": 0,
                    },
                    {
                      "display": "Media",
                      "value": 1,
                    },
                    {
                      "display": "Baja",
                      "value": 2,
                    },
                  ],
                  textField: 'display',
                  valueField: 'value',
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Builder(
                  builder: (context) => RaisedButton(
                    color: Colors.blue,
                    textColor: Colors.white,
                    child: Text("Guardar"),
                    onPressed: () async {
                      if (!_claveFormulario.currentState.validate() ||
                          _icono == null ||
                          _prioridad == null) {
                        showAlertDialog("Error al agregar nota ",
                            "Faltan datos por introducir", false);

                        return;
                      }
                      if(this.nota==null) {
                        BD.arrayNotas.add(new Nota(_titulo.text, _texto.text, _categoria, null, new DateTime.now(), _prioridad));
                        // _texto.clear(); VER SI LO HECHO EN FALTA
                        // _titulo.clear();

                        showAlertDialog(
                            "Nota Agregada",
                            "Seleccione \"continuar\" para volver a la lista de notas",
                            true);
                      }else{

                        BD.arrayNotas[posicion_nota] =new Nota(_titulo.text, _texto.text, _categoria, null, _fecha, _prioridad);
                        showAlertDialog(
                            "Nota Modificada",
                            "Seleccione \"continuar\" para volver a la lista de notas",
                            true);
                      }
                    },
                  ),
                ),
              ),
            ]),
          ),
        ));
  }

  String putCategory(String icon){
    String s;

    switch(icon){
      case "Icons.pool": s="Deporte"; break;
      case "Icons.fastfood": s="Comida"; break;
      case "Icons.school": s="Estudios"; break;
      case "Icons.movie": s="Películas"; break;
      case "Icons.attach_money": s="Diversión"; break;
      case "Icons.fitness_center": s="Gimnasio"; break;
      case "Icons.local_airport": s="Viajes"; break;

      default: break;
    }
    return s;

  }

  void moveToLastScreen() {
    //funcion que hace que vayan para atra

    Navigator.popAndPushNamed(context, ruta);
  }
}




class VisualizarNota extends StatefulWidget {
  Nota _nota;
  DataBase BD;

  @override
  _VisualizarNotaState createState() => _VisualizarNotaState(_nota, BD);

  VisualizarNota(Nota, DataBase bd){this._nota = Nota;this.BD=bd;}
}
class _VisualizarNotaState extends State<VisualizarNota> {
  Nota _nota;
  String prioridad;
  DataBase BD;

  _VisualizarNotaState(nota, DataBase bd){
    this.BD = bd;
    this._nota= nota;
    if(this._nota.prioridad==0){this.prioridad="Alta";}
    if(this._nota.prioridad==1)
    {this.prioridad="Media";}
    if(this._nota.prioridad==2){this.prioridad="Baja";}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Detalles de una nota'),
          backgroundColor: Colors.orangeAccent,
          actions: [
            IconButton(
              icon: Icon(_nota.icono),

            ),
            IconButton(
              tooltip: 'Modificar',
              icon: Icon(Icons.mode_edit),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return AgregarNota(this._nota, BD);
                }));
              },
            ),

          ],
        ),
        body: Container(
          width: 500,
          height: 600,

          decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                    "https://i.pinimg.com/originals/c0/1d/59/c01d598699a64df7b289ddd909339538.jpg"),
                fit: BoxFit.cover,
                // repeat: ImageRepeat.repeat
              )),
          child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  anadirEspacio(),

                  anadirEspacio(),
                  textoConfiguracion("Nombre: ", _nota.titulo),
                  anadirEspacio(),

                  textoConfiguracion("Descripcion: ", _nota.texto),
                  anadirEspacio(),

                  textoConfiguracion("Fecha de Creacion: ",(_nota.fecha.toString().substring(0,10))),
                  anadirEspacio(),

                  textoConfiguracion("Prioridad: ", this.prioridad),
                  anadirEspacio(),
                ],
              )),
          //center centra todo el contenido por lo que ocupa todo el alto y ancho
        ));
  }
}

class Configuracion extends StatelessWidget {
  DataBase BD;

  Configuracion(DataBase bd){this.BD=bd;}


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      //esto es lo que hace que cuando vaya pa atras no se joda
        onWillPop: () {
          Navigator.popAndPushNamed(context,'/' );
        },
        child: Scaffold(
            appBar: AppBar(
              title: Text('Configuración'),
              backgroundColor: Colors.pink,
            ),
            body: Container(
              width: 500,
              height: 600,

              decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(
                        "https://cdn.pixabay.com/photo/2015/06/20/07/24/color-815546_960_720.png"),
                    fit: BoxFit.cover,
                    // repeat: ImageRepeat.repeat
                  )),
              child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      MaterialButton(
                        minWidth: 400.0,
                        height: 30.0,
                        onPressed: null,
                        color: Colors.lightGreen,
                        child: Text('Borrar Notas', style: TextStyle(
                          shadows: [
                            Shadow(
                                color: Colors.black,
                                offset: Offset(0, -5))],
                          color: Colors.transparent,
                          decoration:
                          TextDecoration.underline,
                          decorationColor: Colors.blue,
                          decorationThickness: 4,
                          decorationStyle:
                          TextDecorationStyle.dashed,
                        )),
                      ),
                      MaterialButton(
                        minWidth: 300.0,
                        height: 40.0,
                        onPressed: () {
                          ordenarListaNotas();
                          BD.arrayNotas.removeRange(10, BD.arrayNotas.length);
                        },
                        color: Colors.lightBlue,
                        child: Text('10 Notas (deja las 10 mas recientes)', style: TextStyle(color: Colors.white)),
                      ),
                      MaterialButton(
                        minWidth: 300.0,
                        height: 40.0,
                        onPressed: () {
                          ordenarListaNotas();
                          BD.arrayNotas.removeRange(5, BD.arrayNotas.length);
                        },
                        color: Colors.lightBlue,
                        child: Text('5 Notas (deja las 5 mas recientes)', style: TextStyle(color: Colors.white)),
                      ),

                      MaterialButton(
                        minWidth: 400.0,
                        height: 30.0,
                        onPressed: null,
                        color: Colors.lightGreen,
                        child: Text('Borrar Notas Por Prioridad', style: TextStyle(
                          shadows: [
                            Shadow(
                                color: Colors.black,
                                offset: Offset(0, -5))],
                          color: Colors.transparent,
                          decoration:
                          TextDecoration.underline,
                          decorationColor: Colors.blue,
                          decorationThickness: 4,
                          decorationStyle:
                          TextDecorationStyle.dashed,
                        )),
                      ),
                      MaterialButton(
                        minWidth: 300.0,
                        height: 40.0,
                        onPressed: () {
                          for(int i=0; i<BD.arrayNotas.length;i++){
                            if(BD.arrayNotas[i].prioridad==0){BD.arrayNotas.removeAt(i);i--;} //son listas! no arrays
                          }
                        },
                        color: Colors.lightBlue,
                        child: Text(' Alta', style: TextStyle(color: Colors.white)),
                      ),
                      MaterialButton(
                        minWidth: 300.0,
                        height: 40.0,
                        onPressed: () {
                          for(int i=0; i<BD.arrayNotas.length;i++){
                            if(BD.arrayNotas[i].prioridad==1){BD.arrayNotas.removeAt(i);i--;} //son listas! no arrays
                          }
                        },
                        color: Colors.lightBlue,
                        child: Text('Media', style: TextStyle(color: Colors.white)),
                      ),
                      MaterialButton(
                        minWidth: 300.0,
                        height: 40.0,
                        onPressed: () {
                          for(int i=0; i<BD.arrayNotas.length;i++){
                            if(BD.arrayNotas[i].prioridad==2){BD.arrayNotas.removeAt(i);i--;} //son listas! no arrays
                          }
                        },
                        color: Colors.lightBlue,
                        child: Text(' Baja', style: TextStyle(color: Colors.white)),
                      ),
                      MaterialButton(
                        minWidth: 400.0,
                        height: 30.0,
                        onPressed: null,
                        color: Colors.lightGreen,
                        child: Text('Borrar Todas Las Notas', style: TextStyle(
                          shadows: [
                            Shadow(
                                color: Colors.black,
                                offset: Offset(0, -5))],
                          color: Colors.transparent,
                          decoration:
                          TextDecoration.underline,
                          decorationColor: Colors.blue,
                          decorationThickness: 4,
                          decorationStyle:
                          TextDecorationStyle.dashed,
                        )),
                      ),
                      MaterialButton(
                        minWidth: 300.0,
                        height: 40.0,
                        onPressed: () {
                          BD.arrayNotas.clear();
                        },
                        color: Colors.indigo,
                        child: Text('Borrar', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  )),
              //center centra todo el contenido por lo que ocupa todo el alto y ancho
            )
        ));

  }
  void ordenarListaNotas(){
    Nota aux;
    for (int i = 0; i < BD.arrayNotas.length - 1; i++) {
      for (int j = 0; j < BD.arrayNotas.length - i - 1; j++) {
        if (  BD.arrayNotas[j + 1].fecha.isAfter(BD.arrayNotas[j].fecha) ){
          aux = BD.arrayNotas[j + 1];
          BD.arrayNotas[j + 1] = BD.arrayNotas[j];
          BD.arrayNotas[j] = aux;
        }
      }
    }

  }
}

Widget textoConfiguracion(String cadena, var variable) {
  return Text(cadena + variable.toString(),
      style: TextStyle(color: Colors.pink, fontSize: 25));
}

Widget anadirEspacio() {
  return SizedBox(
    height: 10,
  );
}
