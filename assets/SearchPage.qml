import bb.cascades 1.2
import "tart.js" as Tart

NavigationPane {
    id: searchPage
    property string search: ""
    property string errorText: ""
    property string lastItemType: ""
    property string readerURL: "http://www.readability.com/m?url="
    property bool busy: false
    property int start: 0

    onPopTransitionEnded: {
        page.destroy();
        Application.menuEnabled = ! Application.menuEnabled;
    }

    onPushTransitionEnded: {
        if (page.objectName == 'commentPage') {
            Tart.send('requestPage', {
                    source: page.commentLink,
                    sentBy: 'commentPage',
                    askPost: page.isAsk,
                    deleteComments: "False"
                });
        }
    }

    function onAddSearchStories(data) {
        loading.visible = false;
        searchField.enabled = true;
        errorLabel.visible = false;
        busy = false;
        var story = data.story;
        var lastItem = searchModel.size() - 1
        if (lastItemType == 'error' || lastItemType == 'load') {
            searchModel.removeAt(lastItem)
        }
        searchModel.append({
                type: 'item',
                title: story[0],
                poster: story[1],
                points: story[2],
                commentCount: story[3],
                timePosted: story[4],
                hnid: story[5],
                domain: story[6],
                articleURL: story[7],
                commentsURL: story[8],
                isAsk: story[9]
            });
        lastItemType = 'item'
        start = start + 1;
        searchField.visible = true;
    }
    function onSearchError(data) {
        if (searchModel.isEmpty() != true) {
            var lastItem = searchModel.size() - 1
            if (lastItemType == 'error' || lastItemType == 'load') {
                searchModel.removeAt(lastItem)
            }
            searchModel.append({
                    type: 'error',
                    title: data.text
                });
        } else {
            errorLabel.text = data.text
            errorLabel.visible = true;
        }
        lastItemType = 'error'
        busy = false;
        errorLabel.text = data.text
        searchField.visible = true;
        searchField.enabled = true;
        loading.visible = false;

    }

    Page {
        titleBar: HNTitleBar {
            refreshEnabled: false
            id: titleBar
            listName: searchList
            text: "Reader YC - Search HN"
        }
        Container {
            Container {
                topPadding: 10
                leftPadding: 19
                rightPadding: 19
                TextField {
                    horizontalAlignment: HorizontalAlignment.Center
                    verticalAlignment: verticalAlignment.Top
                    visible: true
                    objectName: "searchField"
                    enabled: true
                    textStyle.color: Color.create("#262626")
                    textStyle.fontSize: FontSize.Medium
                    layoutProperties: StackLayoutProperties {
                        spaceQuota: 1
                    }
                    input {
                        flags: TextInputFlag.AutoCapitalizationOff | TextInputFlag.SpellCheckOff
                    }
                    hintText: qsTr("Search Posts on HN")
                    id: searchField
                    input.onSubmitted: {
                        start = 0;
                        search = searchField.text;
                        searchModel.clear();
                        Tart.send('requestPage', {
                                source: searchField.text,
                                sentBy: 'searchPage',
                                startIndex: start
                            });
                        //start = start + 30;
                        errorLabel.visible = false;
                        loading.visible = true;
                        searchField.visible = false;
                    }
                    input.submitKey: SubmitKey.Search
                }
            }
            Container {
                topPadding: 100
                visible: loading.visible
                horizontalAlignment: HorizontalAlignment.Center
                verticalAlignment: VerticalAlignment.Center
                ActivityIndicator {
                    id: loading
                    minHeight: 300
                    minWidth: 300
                    running: true
                    visible: false
                }
            }
            Container {
                topPadding: 100
                visible: errorLabel.visible
                horizontalAlignment: HorizontalAlignment.Center
                verticalAlignment: VerticalAlignment.Center
                Label {
                    id: errorLabel
                    text: "<b><span style='color:#ff7900'>Try searching for a post!</span></b>"
                    textStyle.fontSize: FontSize.PointValue
                    textStyle.textAlign: TextAlign.Center
                    textStyle.fontSizeValue: 9
                    textStyle.color: Color.DarkGray
                    textFormat: TextFormat.Html
                    multiline: true
                    visible: true
                }
            }

            Container {
                horizontalAlignment: HorizontalAlignment.Center
                verticalAlignment: VerticalAlignment.Center
                ListView {
                    id: searchList
                    dataModel: ArrayDataModel {
                        id: searchModel
                    }
                    function itemType(data, indexPath) {
                        return data.type;
                    }
                    listItemComponents: [
                        ListItemComponent {
                            type: 'item'
                            HNPage {
                                property string type: ListItemData.type
                                postComments: ListItemData.commentCount
                                postTitle: ListItemData.title
                                postDomain: ListItemData.domain
                                postUsername: ListItemData.poster
                                postTime: ListItemData.timePosted + "| " + ListItemData.points
                                postArticle: ListItemData.articleURL
                                askPost: ListItemData.isAsk
                                commentSource: ListItemData.commentsURL
                                commentID: ListItemData.hnid
                            }
                            function openComments(ListItemData) {
                                var page = commentPage.createObject();
                                console.log(ListItemData.commentsURL)
                                page.commentLink = ListItemData.hnid;
                                page.titleDomain = ListItemData.domain;
                                page.title = ListItemData.title;
                                page.titlePoster = ListItemData.poster;
                                page.titleTime = ListItemData.timePosted + "| " + ListItemData.points;
                                page.titleDomain = ListItemData.domain;
                                page.isAsk = ListItemData.isAsk;
                                page.articleLink = ListItemData.articleURL;
                                page.titleComments = ListItemData.commentCount;
                                page.titlePoints = ListItemData.points
                                searchPage.push(page);
                            }
                            function openArticle(ListItemData) {
                                var page = webPage.createObject();
                                page.htmlContent = ListItemData.articleURL;
                                if (settings.readerMode == true && ListItemData.isAsk != "true")
                                    page.htmlContent = readerURL + ListItemData.articleURL;
                                page.text = ListItemData.title;
                                searchPage.push(page);
                            }
                        },
                        ListItemComponent {
                            type: 'error'
                            ErrorItem {
                                id: errorItem
                            }
                        },
                        ListItemComponent {
                            type: 'load'
                            LoadItem {
                                id: loadItem
                                horizontalAlignment: HorizontalAlignment.Center
                                verticalAlignment: VerticalAlignment.Center
                                property string type: ListItemData.type
                            }
                        }
                    ]
                    onTriggered: {
                        var selectedItem = dataModel.data(indexPath);
                        if (dataModel.data(indexPath).type != 'item') {
                            return;
                        }

                        if (settings.openInBrowser == true) {
                            // will auto-invoke after re-arming
                            console.log("OPENING IN BROWSER");
                            linkInvocation.query.uri = "";
                            linkInvocation.query.uri = selectedItem.articleURL;
                            return;
                        }
                        if (settings.readerMode == true && selectedItem.isAsk != "true") {
                            selectedItem.articleURL = readerURL + selectedItem.articleURL;
                            console.log('Item triggered. ' + selectedItem.articleURL);
                            var page = webPage.createObject();
                            page.htmlContent = selectedItem.articleURL;
                            page.text = selectedItem.title;
                            searchPage.push(page);
                            return;
                        }
                        console.log(selectedItem.isAsk);
                        if (selectedItem.isAsk == "true") {
                            console.log("Ask post");
                            var page = commentPage.createObject();
                            console.log(selectedItem.commentsURL)
                            page.commentLink = selectedItem.hnid;
                            page.title = selectedItem.title;
                            page.titlePoster = selectedItem.poster;
                            page.titleTime = selectedItem.timePosted + "| " + selectedItem.points;
                            page.titleDomain = selectedItem.domain;
                            page.isAsk = selectedItem.isAsk;
                            searchPage.push(page);
                            Tart.send('requestPage', {
                                    source: selectedItem.hnid,
                                    sentBy: 'commentPage',
                                    askPost: selectedItem.isAsk,
                                    deleteComments: "false"
                                });
                        } else {
                            console.log('Item triggered. ' + selectedItem.articleURL);
                            var page = webPage.createObject();
                            page.htmlContent = selectedItem.articleURL;
                            page.text = selectedItem.title;
                            searchPage.push(page);
                        }
                    }
                    attachedObjects: [
                        ListScrollStateHandler {
                            onAtEndChanged: {
                                console.log("RES: " + searchModel.size() % 30)
                                if (atEnd == true && searchModel.isEmpty() == false && busy == false && (searchModel.size() % 30) == 0) {
                                    console.log('end reached!');
                                    var lastItem = searchModel.size() - 1;
                                    if (lastItemType == 'load') {
                                        console.log("GLITCHING");
                                        return;
                                    }
                                    if (lastItemType == 'error') { // Remove an error item
                                        searchModel.removeAt(lastItem);
                                    }
                                    searchModel.append({
                                            type: 'load'
                                        });
                                    //searchList.scrollToPosition(ScrollPosition.End, ScrollAnimation.Smooth);
                                    lastItemType = 'load';
                                    Tart.send('requestPage', {
                                            source: search,
                                            startIndex: start,
                                            sentBy: 'searchPage'
                                        });
                                    busy = true;
                                }
                            }
                        }
                    ]
                }
            }
        }
    }
    onCreationCompleted: {
        Tart.register(searchPage)
    }
    attachedObjects: [
        Invocation {
            id: linkInvocation
            property bool auto_trigger: false
            query {
                uri: "http://peterhansen.ca"
                invokeTargetId: "sys.browser"

                onUriChanged: {
                    if (uri != "") {
                        linkInvocation.query.updateQuery();
                    }
                }
            }

            onArmed: {
                // don't auto-trigger on initial setup
                if (auto_trigger)
                    trigger("bb.action.OPEN");
                auto_trigger = true; // allow re-arming to auto-trigger
            }
        },
        ComponentDefinition {
            id: webPage
            source: "webArticle.qml"
        },
        ComponentDefinition {
            id: commentPage
            source: "CommentPage.qml"
        },
        ComponentDefinition {
            id: userPage
            source: "UserPage.qml"
        }
    ]
}
