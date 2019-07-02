// Copyright (C) 2019  Nathan van Beelen (CLA signed)
//
// This file is part of Pattle.
//
// Pattle is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// Pattle is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with Pattle.  If not, see <https://www.gnu.org/licenses/>.
import 'package:matrix_sdk/matrix_sdk.dart';                                    
import 'package:pattle/src/ui/main/models/chat_item.dart';                      
import 'package:pattle/src/ui/main/sync_bloc.dart';                             
import 'package:pattle/src/ui/util/room.dart';                                  
import 'package:rxdart/rxdart.dart';                                            

class ImageBloc {

  Room room;
  ImageMessageEvent event;

  ImageBloc(this.event);

  PublishSubject<bool> _isLoadingEventsSubj = PublishSubject<bool>();
  Stream<bool> get isLoadingEvents => _isLoadingEventsSubj.stream.distinct();

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  set isLoading(bool value) {
    _isLoading = value;
    if (!isLoading) {
      _isLoadingEventsSubj.add(false);
    } else {
      // If still loading after 2 seconds, notify the UI
      Future.delayed(const Duration(seconds: 2), () {
        if (isLoading) {
          _isLoadingEventsSubj.add(true);
        }
      });
    }
  }

  PublishSubject<List<ImageMessageEvent>> _eventSubj 
      = PublishSubject<List<ImageMessageEvent>>();
  Stream<List<ImageMessageEvent>> get events => _eventSubj.stream;

  Future<void> startLoadingEvents() async {
    await loadEvents();

    syncBloc.stream.listen((success) async => await loadEvents());
  }

  Future<void> loadEvents() async {
    final imageMessageEvents = List<ImageMessageEvent>();

    RoomEvent event;
    await for (event in room.timeline.get(allowRemote: false)) {
      if (event is ImageMessageEvent) {
        imageMessageEvents.add(event);
      }
    }

    _eventSubj.add(List.of(imageMessageEvents));
  }
}
