import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/rendering.dart';
import 'package:share/share.dart';

import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/interface/collection/collectionalbum.dart';
import 'package:harmonoid/interface/collection/collectiontrack.dart';
import 'package:harmonoid/utils/widgets.dart';
import 'package:harmonoid/constants/language.dart';


class CollectionSearch extends StatefulWidget {
  CollectionSearch({Key? key}) : super(key: key);
  CollectionSearchState createState() => CollectionSearchState();
}


class CollectionSearchState extends State<CollectionSearch> {
  int elementsPerRow = 2;
  double? tileWidth;
  double? tileHeight;
  TextEditingController textFieldController = new TextEditingController();
  String query = '';
  bool get search => this._albums.length == 0 && this._tracks.length == 0 && this.textFieldController.text == '';
  bool get result => this._albums.length == 0 && this._tracks.length == 0 && this.textFieldController.text != '';
  bool get albums => this._albums.length == 0;
  bool get tracks => this._tracks.length == 0;
  List<Widget> _albums = <Widget>[];
  List<Widget> _tracks =  <Widget>[];
  List<Widget> _artists =  <Widget>[];

  @override
  Widget build(BuildContext context) {
    if (query == this.textFieldController.text) {
      this._albums = <Widget>[];
      this._tracks =  <Widget>[];
      this._artists =  <Widget>[];
      textFieldController.clear();
    }
    else {
      this.query = this.textFieldController.text;
    }
    this.elementsPerRow = MediaQuery.of(context).size.width ~/ (156 + 8);
    this.tileWidth = (MediaQuery.of(context).size.width - 16 - (this.elementsPerRow - 1) * 8) / this.elementsPerRow;
    this.tileHeight = this.tileWidth! * 242 / 156;
    return Consumer<Collection>(
      builder: (context, collection, _) => Scaffold(
        appBar: AppBar(
          title: TextField(
            autofocus: true,
            controller: this.textFieldController,
            cursorWidth: 1.0,
            onChanged: (String query) async {
              this._albums.clear();
              this._tracks.clear();
              this._artists.clear();
              List<dynamic> resultCollection = await collection.search(query);
              for (dynamic collectionItem in resultCollection) {
                if (collectionItem is Album) {
                  this._albums.add(
                    Container(
                      margin: EdgeInsets.only(top: 8.0, bottom: 8.0, right: 8.0),
                      child: CollectionAlbumTile(
                        height: this.tileHeight,
                        width: this.tileWidth,
                        album: collectionItem,
                      ),
                    ),
                  );
                }
                else if (collectionItem is Track) {
                  this._tracks.add(
                    CollectionTrackTile(
                      track: collectionItem,
                      popupMenuButton: PopupMenuButton(
                        elevation: 2,
                        onSelected: (index) {
                          switch (index) {
                            case 0:
                              showDialog(
                                context: context,
                                builder: (subContext) => AlertDialog(
                                  title: Text(
                                    language!
                                        .STRING_LOCAL_ALBUM_VIEW_TRACK_DELETE_DIALOG_HEADER,
                                    style: Theme.of(subContext).textTheme.headline1,
                                  ),
                                  content: Text(
                                    language!
                                        .STRING_LOCAL_ALBUM_VIEW_TRACK_DELETE_DIALOG_BODY,
                                    style: Theme.of(subContext).textTheme.headline5,
                                  ),
                                  actions: [
                                    MaterialButton(
                                      textColor: Theme.of(context).primaryColor,
                                      onPressed: () async {
                                        await collection.delete(collection.tracks[index]);
                                        Navigator.of(subContext).pop();
                                      },
                                      child: Text(language!.STRING_YES),
                                    ),
                                    MaterialButton(
                                      textColor: Theme.of(context).primaryColor,
                                      onPressed: Navigator.of(subContext).pop,
                                      child: Text(language!.STRING_NO),
                                    ),
                                  ],
                                ),
                              );
                              break;
                            case 1:
                              Share.shareFiles(
                                [collection.tracks[index].filePath!],
                                subject:
                                    '${collection.tracks[index].trackName} - ${collection.tracks[index].albumName}. Shared using Harmonoid!',
                              );
                              break;
                            case 2:
                              showDialog(
                                context: context,
                                builder: (subContext) => AlertDialog(
                                  contentPadding: EdgeInsets.zero,
                                  actionsPadding: EdgeInsets.zero,
                                  title: Text(
                                    language!.STRING_PLAYLIST_ADD_DIALOG_TITLE,
                                    style: Theme.of(subContext).textTheme.headline1,
                                  ),
                                  content: Container(
                                    height: 280,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.fromLTRB(24, 8, 0, 16),
                                          child: Text(
                                            language!.STRING_PLAYLIST_ADD_DIALOG_BODY,
                                            style: Theme.of(subContext).textTheme.headline5,
                                          ),
                                        ),
                                        Container(
                                          height: 236,
                                          width: 280,
                                          decoration: BoxDecoration(
                                            border: Border.symmetric(
                                              vertical: BorderSide(
                                                color: Theme.of(context).dividerColor,
                                                width: 1,
                                              ),
                                            ),
                                          ),
                                          child: ListView.builder(
                                            shrinkWrap: true,
                                            itemCount: collection.playlists.length,
                                            itemBuilder: (context, playlistIndex) {
                                              return ListTile(
                                                title: Text(
                                                  collection
                                                      .playlists[playlistIndex].playlistName!,
                                                  style:
                                                      Theme.of(context).textTheme.headline2,
                                                ),
                                                leading: Icon(
                                                  Icons.queue_music,
                                                  size: Theme.of(context).iconTheme.size,
                                                  color: Theme.of(context).iconTheme.color,
                                                ),
                                                onTap: () async {
                                                  await collection.playlistAddTrack(
                                                    collection.playlists[playlistIndex],
                                                    collection.tracks[index],
                                                  );
                                                  Navigator.of(subContext).pop();
                                                },
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  actions: [
                                    MaterialButton(
                                      textColor: Theme.of(context).primaryColor,
                                      onPressed: Navigator.of(subContext).pop,
                                      child: Text(language!.STRING_CANCEL),
                                    ),
                                  ],
                                ),
                              );
                              break;
                          }
                        },
                        icon: Icon(Icons.more_vert,
                            color: Theme.of(context).iconTheme.color,
                            size: Theme.of(context).iconTheme.size),
                        tooltip: language!.STRING_OPTIONS,
                        itemBuilder: (_) => <PopupMenuEntry>[
                          PopupMenuItem(
                            value: 0,
                            child: Text(language!.STRING_DELETE),
                          ),
                          PopupMenuItem(
                            value: 1,
                            child: Text(language!.STRING_SHARE),
                          ),
                          PopupMenuItem(
                            value: 2,
                            child: Text(language!.STRING_ADD_TO_PLAYLIST),
                          ),
                        ],
                      ),
                    ),
                  );
                }
              }
              this.setState(() {});
            },
            decoration: InputDecoration.collapsed(hintText: language!.STRING_SEARCH_COLLECTION),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color),
            iconSize: Theme.of(context).iconTheme.size!,
            splashRadius: Theme.of(context).iconTheme.size! - 8,
            onPressed: Navigator.of(context).pop,
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.close, color: Theme.of(context).iconTheme.color),
              iconSize: Theme.of(context).iconTheme.size!,
              splashRadius: Theme.of(context).iconTheme.size! - 8,
              tooltip: language!.STRING_OPTIONS,
              onPressed: this.textFieldController.clear,
            ),
          ],
        ),
        body: ListView(
          children: <Widget>[
            this.search ? Container(
              margin: EdgeInsets.only(top: 56),
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: [
                  Icon(Icons.search, size: 72, color: Theme.of(context).iconTheme.color),
                  Divider(
                    color: Colors.transparent,
                    height: 8,
                  ),
                  Text(
                    language!.STRING_LOCAL_SEARCH_WELCOME,
                    style: Theme.of(context).textTheme.headline5,
                  )
                ],
              ),
            ) : Container(),
            this.result ? Container(
              margin: EdgeInsets.only(top: 56),
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: [
                  Icon(Icons.close, size: 72, color: Theme.of(context).iconTheme.color),
                  Divider(
                    color: Colors.transparent,
                    height: 8,
                  ),
                  Text(
                    language!.STRING_LOCAL_SEARCH_NO_RESULTS,
                    style: Theme.of(context).textTheme.headline5,
                  )
                ],
              ),
            ) : Container(),
            this.albums ? Container(): SubHeader(language!.STRING_LOCAL_SEARCH_ALBUM_SUBHEADER),
            this.albums ? Container(): Container(
              margin: EdgeInsets.only(left: 8.0),
              height: this.tileHeight! + 16.0,
              width: MediaQuery.of(context).size.width,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: this._albums,
              ),
            ),
            this.tracks ? Container(): SubHeader(language!.STRING_LOCAL_SEARCH_TRACK_SUBHEADER),
          ] + (this.tracks ? [Container()]: this._tracks),
        ),
      ),
    );
  }
}
