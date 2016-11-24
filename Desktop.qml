import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Web 0.2
import com.canonical.Oxide 1.0 as Oxide



    Page {
        id: pageDesktop
        visible: false

        header: PageHeader {
            id: pageHeader
            title: i18n.tr("Fmessenger")
            StyleHints {
                foregroundColor: "#FFFFFF"
                backgroundColor: "#0084FF"

            }

            leadingActionBar {
                           numberOfSlots:3
                           actions: [

                               Action {
                                   id: actionForward
                                   iconName: "go-next"
                                   text: i18n.tr("Forward")
                                   onTriggered:  {
                                       webview.goForward()
                                   }
                                    },

                                  Action {
                                   id: actionRestore
                                   iconSource: "icon.svg"
                                                       iconName: "icon"
                                                       onTriggered: {
                                                           webview.url = 'https://www.messenger.com/'
                                                       }
                                                       text: qsTr("Messenger")
                                                   },
                                   Action {
                                       id: actionBack
                                       iconName: "go-previous"
                                       text: i18n.tr("Back")
                                       onTriggered: {
                                           webview.goBack()
                                       }
                                   }
                           ]
                       }
            trailingActionBar {
                                                  numberOfSlots: 3
                                                  actions: [
                                                      Action {
                                                          id: actionfacebook
                                                          iconName: "facebook-symbolic"
                                                          onTriggered: {
                                                                                 webview.url = 'https://www.facebook.com/'
                                                                             }
                                                           },
                                                      Action {
                                                          id: actionDesktopone
                                                          iconName: "computer-symbolic"
                                                          text: i18n.tr("Desktop view")

                                                           },
                                                      Action {
                                                          id: actionPhone
                                                          iconName: "phone-smartphone-symbolic"
                                                          text: i18n.tr("Phone view")
                                                          onTriggered: {
                                                                            onClicked: mainPageStack.pop(pageDesktop)
                                                                        }
                                                           },
                                                      Action {
                                                          id: actionAbout
                                                          iconName: "info"
                                                          text: i18n.tr("About")
                                                          onTriggered:  mainPageStack.push(Qt.resolvedUrl("About.qml"))
                                                           }



                                                  ]
                                              }
        }

        WebContext {
                    id: webcontext
                    userAgent: myUA
                    userScripts: [
                            Oxide.UserScript {
                                context: "oxide://"
                                url: Qt.resolvedUrl("./userscripts/desktop.js")
                                matchAllFrames: true
                            }
                        ]
                    }

        WebView {


                    id: webview
                    anchors {
                        fill: parent
                        bottom: parent.bottom
                        top: pageHeader.bottom
                        topMargin: units.gu(6)

                    }



                    context: webcontext
                    url: "https://www.messenger.com/login.php"
                    preferences.localStorageEnabled: true
                    preferences.allowFileAccessFromFileUrls: true
                    preferences.allowUniversalAccessFromFileUrls: true
                    preferences.appCacheEnabled: true
                    preferences.javascriptCanAccessClipboard: true
                    filePicker: filePickerLoader.item
 
                    function navigationRequestedDelegate(request) {
                                    var url = request.url.toString();
                                    var pattern = myPattern.split(',');
                                    var isvalid = false;

                                    if (Conf.hapticLinks) {
                                        vibration.start()
                                    }

                                    if (Conf.audibleLinks) {
                                        clicksound.play()
                                    }

                                    for (var i=0; i<pattern.length; i++) {
                                        var tmpsearch = pattern[i].replace(/\*/g,'(.*)')
                                        var search = tmpsearch.replace(/^https\?:\/\//g, '(http|https):\/\/');
                                        if (url.match(search)) {
                                           isvalid = true;
                                           break
                                        }
                                    }
                                    if(isvalid == false) {
                                        console.warn("Opening remote: " + url);
                                        Qt.openUrlExternally(url)
                                        request.action = Oxide.NavigationRequest.ActionReject
                                    }
                                }
                                Component.onCompleted: {
                                    preferences.localStorageEnabled = true
                                    if (Qt.application.arguments[1].toString().indexOf(myUrl) > -1) {
                                        console.warn("got argument: " + Qt.application.arguments[1])
                                        url = Qt.application.arguments[1]
                                    }
                                    console.warn("url is: " + url)
                                }
                                onGeolocationPermissionRequested: { request.accept() }
                                Loader {
                                    id: filePickerLoader
                                    source: "ContentPickerDialog.qml"
                                    asynchronous: true
                                }
                            }
        Connections {
                target: UriHandler
                onOpened: {
                    if (uris.length === 0 ) {
                        return;
                    }
                    webview.url = uris[0]
                    console.warn("uri-handler request")
                }
            }


        }
