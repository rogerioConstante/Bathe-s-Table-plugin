//=========================================================================================\\
//  Bathe Table Intervalos v0.2                                                            \\
//                                                                                         \\
//  Copyright (C)2024 Rogério Tavares Constante                                            \\
//                                                                                         \\
//  Este programa é um software livre: você pode redistribuir e/ou  modificar              \\
//  ele nos termos da GNU General Public License como publicada pela                       \\
//  Free Software Foundation, seja na versão 3 da licença, ou em qualquer outra posterior. \\
//                                                                                         \\
//  Este programa é distribuído com a intenção de que seja útil,                           \\
//  mas SEM NENHUMA GARANTIA; Veja a GNU para mais detalhes.                               \\
//                                                                                         \\
//  Uma cópia da GNU General Public License pode ser encontrada em                         \\
//  <http://www.gnu.org/licenses/>.                                                        \\
//                                                                                         \\
//=========================================================================================\\

import QtQuick 2.5
import QtQuick.Controls 1.3
import QtQuick.Dialogs 1.2
import QtQuick.Window 2.1
import MuseScore 3.0

MuseScore {
      menuPath: "Plugins.Contraponto.BatheTableCourse"
      description: "Bathe's Table Course.\nPlugin para analisar o movimento melódico do CF (course) e escrever os intervalos viáveis, segundo a tabela de William Bathe."
      version: "0.2"

      //4.4 title: "Bathe's Table Course"
      //4.4 thumbnailName: "CapaBathe.png"
      //4.4 categoryCode: "Contraponto"

      Component.onCompleted: {
        if (mscoreMajorVersion >= 4) {
            title = qsTr("Bathe's Table Course")
            thumbnailName = "CapaBathe.png"
            categoryCode = "Contraponto"
        }
      }

// ----------------------------------------------------------------------------------------------------------------
MessageDialog {
      id: msgErros
      title: "Erros!"
      text: "-"
      property bool estado: false
      onAccepted: {
            msgErros.visible=false;
      }

      visible: false;
} // msgErros

ApplicationWindow {
    id: window
    visible: true
    width: 820
    height: 380
    title: "Intervalo da imitação"

    Rectangle {
        id: windowPrompt
        width: parent.width
        height: parent.height
        anchors.horizontalCenter: parent.horizontalCenter
        color: "green"

          Image {
            id: tabelaIm
            source: "BatheTable.png" // Caminho para a imagem
            anchors.left: parent.left // Alinha à borda esquerda da janela
            anchors.top: parent.top // Alinha à borda superior da janela
            anchors.margins: 10 // Margem opcional do canto
            width: 800 // Largura da imagem
            height: 300 // Altura da imagem
          }

          Text {
            id: texto
            text: "Escolha o intervalo e a direção:"
            font.bold: true
            font.pointSize: 9
            color: "#fcffbc"
            anchors.top: tabelaIm.bottom
            anchors.left: parent.left
            anchors.margins: 10
            //anchors.margins: 2
          }
          Button {
              id: btDir
              text: "Acima"
              anchors.top: tabelaIm.bottom
              anchors.left: parent.left
              anchors.leftMargin: 350
              anchors.topMargin: 5
              width: 60
              menu: menuDir
              x: 5; y: 25
              Text { x: 62; color: "#fcffbc"; anchors.verticalCenter: parent.verticalCenter; font.pixelSize: 13; text: qsTr("Direção") }
            }
          Menu {
              id: menuDir
              property int value: 1
                      MenuItem { text: "Acima"; onTriggered: { menuDir.value = 1; btDir.text = "Acima" } }
                      MenuItem { text: "Abaixo"; onTriggered: { menuDir.value = 2; btDir.text = "Abaixo" } }
                  }

          Button {
              id: btInt
              text: "1"
              anchors.top: tabelaIm.bottom
              anchors.left: parent.left
              anchors.leftMargin: 220
              anchors.topMargin: 5
              width: 60
              menu: menuInt
              x: 5; y: 60
              Text { x: 62; color: "#fcffbc"; anchors.verticalCenter: parent.verticalCenter; font.pixelSize: 13; text: qsTr("Intervalo") }
            }
          Menu {
              id: menuInt
              property int value: 1
                      MenuItem { text: "1"; onTriggered: { menuInt.value = 1; btInt.text = "1" } }
                      MenuItem { text: "2"; onTriggered: { menuInt.value = 2; btInt.text = "2" } }
                      MenuItem { text: "3"; onTriggered: { menuInt.value = 3; btInt.text = "3" } }
                      MenuItem { text: "4"; onTriggered: { menuInt.value = 4; btInt.text = "4" } }
                      MenuItem { text: "5"; onTriggered: { menuInt.value = 5; btInt.text = "5" } }
                      MenuItem { text: "6"; onTriggered: { menuInt.value = 6; btInt.text = "6" } }
                      MenuItem { text: "7"; onTriggered: { menuInt.value = 7; btInt.text = "7" } }
                      MenuItem { text: "8"; onTriggered: { menuInt.value = 8; btInt.text = "8" } }
                  }

          Item {
              width: parent.width
              height: 40
              anchors.left: parent.left
              anchors.leftMargin: 10
              anchors.bottom: parent.bottom

              Button {
                text: "Anotar intervalos"
                onClicked: {
                    carregarNotas();
                    mostraIntervalos();
                    console.log("anotar!")
                }
              }
          }
    }

}

// ---- variáveis globais ----
      property var vozes: [];
      property var direção: "";
      property var place: 0;
      property bool finaliza: false;
      property var tabela: [
        ["Observation VI", "8/5", "11", "10", "9", "8", "7", "6"],
        ["Observation V", "1", "7", "6", "5", "4", "3", "2"],
        ["Observation IV", "7", "6", "5", "4", "3", "2", "1"],
        ["Observation III", "2", "1", "7", "6", "5", "4", "3"],
        ["Observation II", "5", "6", "7", "1", "2", "3", "4"],
        ["Observation I", "1", "2", "3", "4", "5", "6", "7"],
        ["Places up", "1", "7", "6", "5", "4", "3", "2"],
        ["Course up 1 - Course down 8", "1/3/5/6", "6", "1/3/5", "1/6", "3/5", "1/3/6", "5"],
        ["Course up 2 - Course down 7", "6", "1/3/5", "1/6", "3/5", "1/3/6", "5", "1/3/5/6"],
        ["Course up 3 - Course down 6", "1/3/5", "1/6", "3/5", "1/3/6", "5", "1/3/5/6", "6"],
        ["Course up 4 - Course down 5", "1/6", "3/5", "1/3/6", "5", "1/3/5/6", "6", "1/3/5"],
        ["Course up 5 - Course down 4", "3/5", "1/3/6", "5", "1/3/5/6", "6", "1/3/5", "1/6"],
        ["Course up 6 - Course down 3", "1/3/6", "5", "1/3/5/6", "6", "1/3/5", "1/6", "3/5"],
        ["Course up 7 - Course down 2", "5", "1/3/5/6", "6", "1/3/5", "1/6", "3/5", "1/3/6"],
        ["Course up 8 - Course down 1", "1/3/5/6", "6", "1/3/5", "1/6", "3/5", "1/3/6", "5"],
        ["Places down", "1", "2", "3", "4", "5", "6", "7"],
        ["Observation I", "1", "2", "3", "4", "5", "6", "7"],
        ["Observation II", "5", "6", "7", "1", "2", "3", "4"],
        ["Observation III", "2", "3", "4", "5", "6", "7", "1"],
        ["Observation IV", "7", "1,", "2", "3", "4", "5", "6"],
        ["Observation V", "1", "2", "3", "4", "5", "6", "7"],
        ["Observation VI", "5", "6", "7", "8", "9", "10", "11"]
      ];


// ----------- funções ---------
function tpc2Int(st) { // converte intervalo tpc para intervalos
  switch(st){
   case -7: return 1;
   case 0: return 1;
   case 7: return 1;
   case -12: return 2;
   case -5: return 2;
   case 2: return 2;
   case 9: return 2;
   case -10: return 3;
   case -3: return 3;
   case 4: return 3;
   case 11: return 3;
   case -8: return 4;
   case -1: return 4;
   case 6: return 4;
   case -6: return 5;
   case 1: return 5;
   case 8: return 5;
   case -11: return 6;
   case -4: return 6;
   case 3: return 6;
   case 10: return 6;
   case -9: return 7;
   case -2: return 7;
   case 5: return 7;
   case 12: return 7;
  };
}

function mostraIntervalos() {
 curScore.startCmd();
 var cursor = curScore.newCursor();
 var dir;
 cursor.rewind(0);

 var obs = newElement(Element.STAFF_TEXT);
 var txtObs;
   if (menuDir.value == 1) { var pos2 = 9 - menuInt.value; if (pos2 == 8) { pos2 = 1; };
     txtObs = "Obs. I e II: ";
     txtObs += tabela[4][pos2] + "," + tabela[5][pos2] + "\n";
     txtObs += "Obs. III e IV: ";
     txtObs += tabela[2][pos2] + "^," + tabela[3][pos2] + "^," + tabela[18][pos2] + "v," + tabela[19][pos2] + "v\n";
     txtObs += "Obs. V e VI: ";
     txtObs += tabela[0][pos2] + "^," + tabela[1][pos2] + "^," + tabela[20][pos2] + "v," + tabela[21][pos2] + "v";
  } else
   if (menuDir.value == 2) {
     var pos2 = menuInt.value;
     txtObs = "Obs. I e II: ";
     txtObs += tabela[16][pos2] + "," + tabela[17][pos2] + "\n";
     txtObs += "Obs. III e IV: ";
     txtObs += tabela[2][pos2] + "^," + tabela[3][pos2] + "^," + tabela[18][pos2] + "v," + tabela[19][pos2] + "v\n";
     txtObs += "Obs. V e VI: ";
     txtObs += tabela[0][pos2] + "^," + tabela[1][pos2] + "^," + tabela[20][pos2] + "v," + tabela[21][pos2] + "v";
  };
  obs.text = txtObs;
  obs.text.pointSize = 8;
  //console.log(obs.text);
  obs.placement = 0;
  obs.autoplace = false;
  cursor.add(obs);


  for (var x=0;x<vozes.length-1;x++) {	// percorre acordes
       cursor.rewind(0);
  	if (!cursor.segment) { cursor.rewind(0) };

  if (vozes[x].nota[0] == 1000 || vozes[x+1].nota[0] == 1000) { var int1 = "erro"; }
   else {
    	var int2 = vozes[x+1].nota[0]-vozes[x].nota[0];  // intervalo em semitons
      if (int2 < 0) {
        dir = "desc";
        var int1 = tpc2Int(vozes[x].tonal[0]-vozes[x+1].tonal[0]);

      } else {
        dir = "asc";
        var int1 = tpc2Int(vozes[x+1].tonal[0]-vozes[x].tonal[0]);
      };// intervalo simples: classificação
   };

   if (int1 == 0 && (int2 == 12 || int2 == -12)) { int1 == 8; };

    cursor.staffIdx = Math.floor(vozes[x].trilha[0] / 4);    // posicionar cursor para encontrar x
    while (cursor.tick < vozes[x].posição[0]) { cursor.next(); };
    cursor.staffIdx = Math.floor(vozes[x].trilha[0] / 4);    // reposicionar cursor para impressao no y
    console.log(x, cursor.tick);

    var myText = newElement(Element.STAFF_TEXT);
        if ((!int1 && int1 !== 0) || int1 == "erro") { myText.text = ""; } else {
          if (dir == "asc") { var pos = 6 + int1; } else
            if (dir == "desc") { var pos = 6 + (9 - int1); };
          if (menuDir.value == 1) { var pos2 = 9 - menuInt.value; if (pos2 == 8) { pos2 = 1; }; } else
            if (menuDir.value == 2) { var pos2 = menuInt.value; };
          myText.text = tabela[pos][pos2];
        };
        if (myText.text.length == 1) { myText.offsetX = 0.3; } else
        if (myText.text.length == 2) { myText.offsetX = 0.2; } else
        if (myText.text.length == 3) { myText.offsetX = 0.1; } else
        if (myText.text.length == 4) { myText.offsetX = 0; };
        if (vozes[0].tonal.length == 2) { myText.offsetY = 6; } else { myText.offsetY = 4; }
        myText.placement = 1;
        myText.autoplace = false;
        cursor.add(myText);
    };
   //};
  //};
 curScore.endCmd();
}

function carregarNotas() {

  console.log("Tabela de Bathe ......................................... Rogério Tavares Constante - 2024(c)")

  if (typeof curScore == 'undefined' || curScore == null) { // verifica se há partitura
     console.log("nenhuma partitura encontrada");
     msgErros.text = "Erro! \n Nenhuma partitura encontrada!";
                       msgErros.visible=true; finaliza = true; return; };

  //procura por uma seleção
  var pautaInicial;
  var pautaFinal;
  var posFinal;
  var posInicial;
  var processaTudo = false;
  vozes = [];
  var cursor = curScore.newCursor();

  cursor.rewind(1);

    if (!cursor.segment) {
       // no selection
       console.log("nenhuma seleção: processando toda partitura");
       processaTudo = true;
       pautaInicial = 0;
       pautaFinal = curScore.nstaves;

     } else {
       pautaInicial = cursor.staffIdx;
       posInicial = cursor.tick;
       cursor.rewind(2);
       pautaFinal = cursor.staffIdx + 1;
       posFinal = cursor.tick;
          if(posFinal == 0) {  // se seleção vai até o final da partitura, a posição do fim da seleção (rewind(2)) é 0.
          							// para poder calcular o tamanho do segmento, pega a última posição da partitura (lastSegment.tick) e adiciona 1.
          posFinal = curScore.lastSegment.tick + 1;
          }
       cursor.rewind(1);
    };

  // ------------------ inicializa variáveis de dados

          var seg = 0;
          var carregou;
          var trilha;
          var trilhaInicial = pautaInicial * 4;
          var trilhaFinal = pautaFinal * 4;

          // lê as informações da seleção (ou do documento inteiro, caso não haja seleção)
          if(processaTudo) { // posiciona o cursor no início
                cursor.rewind(0);
          } else {
                cursor.rewind(1);
          };

          var segmento = cursor.segment;
          var pausa = false;
          while (segmento && (processaTudo || segmento.tick < posFinal)) {
              carregou = false;
              var voz = 0;
              vozes[seg] = { nota: [], tonal: [], posição: [], duração: [], trilha: [], objeto: []};
              // Passo 1: ler as notas e guardar em "vozes"
              for (trilha = trilhaInicial; trilha < trilhaFinal; trilha++) {
              cursor.track = trilha;
                if (segmento.elementAt(trilha)) {
                    if (segmento.elementAt(trilha).type == Element.CHORD) {
                    var duração = segmento.elementAt(trilha).duration.ticks;
                    var notas = segmento.elementAt(trilha).notes;
                    for (var j=notas.length-1; j>=0;j--) {
                      vozes[seg].nota[voz] = notas[j].pitch;
                      vozes[seg].tonal[voz] = notas[j].tpc
                      vozes[seg].trilha[voz] = trilha;
                      vozes[seg].posição[voz] = segmento.tick;
                      vozes[seg].duração[voz] = duração;
                      vozes[seg].objeto[voz] = notas[j];
                      voz++;
                      carregou = true;
                    };
                  };
                };
              };

              if (carregou) {
                  var menorDura = 0;
                  for (var i=1;i<vozes[seg].nota.length;i++) {
                      if (vozes[seg].duração[i] < vozes[seg].duração[menorDura]) { menorDura =  i};
                  };
                  cursor.track = vozes[seg].trilha[menorDura];
                  seg++;
              };
              cursor.next(); segmento = cursor.segment;
          };
          if (seg == 0) { msgErros.text += "Nenhum acorde carregado!!\n";
                      msgErros.estado=true; (typeof(quit) === 'undefined' ? Qt.quit : quit)(); };
          console.log("acordes carregados:", vozes.length);
}
// --------------------------------------

  onRun: {
     window.visible = true;
     window.raise();
     finaliza = false;
     msgErros.text = "";
     msgErros.estado = false;

     if (finaliza) { (typeof(quit) === 'undefined' ? Qt.quit : quit)(); };

  } // fecha onRun
} // fecha função Musescore
