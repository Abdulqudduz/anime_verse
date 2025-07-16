import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:inkino/assets.dart';
import 'package:inkino/message_provider.dart';
import 'package:inkino/ui/event_details/actor_scroller.dart';
import 'package:inkino/ui/event_details/event_backdrop_photo.dart';
import 'package:inkino/ui/event_details/event_details_scroll_effects.dart';
import 'package:inkino/ui/event_details/event_gallery_grid.dart';
import 'package:inkino/ui/event_details/storyline_widget.dart';
import 'package:inkino/ui/events/event_poster.dart';
import 'package:inkino/ui/showtimes/showtime_list_tile.dart';
import 'package:kt_dart/collection.dart';

class EventDetailsPage extends StatefulWidget {
  const EventDetailsPage(this.event, {super.key, this.show});

  final Event event;
  final Show? show;

  @override
  State<EventDetailsPage> createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage> {
  late final ScrollController _scrollController;
  late final EventDetailsScrollEffects _scrollEffects;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_scrollListener);
    _scrollEffects = EventDetailsScrollEffects(context);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    setState(() {
      _scrollEffects.updateScrollOffset(context, _scrollController.offset);
    });
  }

  Widget _buildShowtimeInformation() {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ShowtimeListTile(
          widget.show!,
          opensEventDetails: false,
        ),
      ),
    );
  }

  Widget _buildSynopsis() {
    if (!widget.event.hasSynopsis) return const SizedBox.shrink();

    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        top: widget.show == null ? 12.0 : 0.0,
        bottom: 16.0,
      ),
      child: StorylineWidget(widget.event),
    );
  }

  Widget _buildActorScroller() {
    return widget.event.actors!.isNotEmpty()
        ? ActorScroller(widget.event)
        : const SizedBox.shrink();
  }

  Widget _buildGallery() {
    return widget.event.galleryImages!.isNotEmpty()
        ? EventGalleryGrid(widget.event)
        : Container(color: Colors.white, height: 500.0);
  }

  Widget _buildEventBackdrop() {
    return Positioned(
      top: _scrollEffects.headerOffset,
      child: EventBackdropPhoto(
        event: widget.event,
        scrollEffects: _scrollEffects,
      ),
    );
  }

  Widget _buildStatusBarBackground() {
    final statusBarColor = Theme.of(context).primaryColor;

    return Container(
      height: _scrollEffects.statusBarHeight,
      color: statusBarColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> content = [
      _Header(widget.event),
      _buildShowtimeInformation(),
      _buildSynopsis(),
      _buildActorScroller(),
      _buildGallery(),
      const SizedBox(height: 32.0),
    ];

    final backgroundImage = Positioned.fill(
      child: Image.asset(
        ImageAssets.backgroundImage,
        fit: BoxFit.cover,
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F0),
      body: Stack(
        children: [
          backgroundImage,
          _buildEventBackdrop(),
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverList(delegate: SliverChildListDelegate(content)),
            ],
          ),
          _BackButton(scrollEffects: _scrollEffects),
          _buildStatusBarBackground(),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header(this.event);

  final Event event;

  @override
  Widget build(BuildContext context) {
    final moviePoster = Padding(
      padding: const EdgeInsets.all(6.0),
      child: EventPoster(
        event: event,
        size: const Size(125.0, 187.5),
        displayPlayButton: true,
      ),
    );

    return Stack(
      children: [
        Container(
          height: 225.0,
          margin: const EdgeInsets.only(bottom: 132.0),
        ),
        Positioned(
          bottom: 0.0,
          left: 0.0,
          right: 0.0,
          child: Container(
            color: Colors.white,
            height: 132.0,
          ),
        ),
        Positioned(
          left: 10.0,
          bottom: 0.0,
          child: moviePoster,
        ),
        Positioned(
          top: 238.0,
          left: 156.0,
          right: 16.0,
          child: _EventInfo(event),
        ),
      ],
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.scrollEffects});

  final EventDetailsScrollEffects scrollEffects;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top,
      left: 4.0,
      child: IgnorePointer(
        ignoring: scrollEffects.backButtonOpacity == 0.0,
        child: Material(
          type: MaterialType.circle,
          color: Colors.transparent,
          child: BackButton(
            color: Colors.white.withOpacity(
              scrollEffects.backButtonOpacity * 0.9,
            ),
          ),
        ),
      ),
    );
  }
}

class _EventInfo extends StatelessWidget {
  const _EventInfo(this.event);

  final Event event;

  List<Widget> _buildTitleAndLengthInMinutes() {
    final length = '${event.lengthInMinutes} min';
    final genres = event.genres!.split(', ').take(4).join(', ');

    return [
      Text(
        event.title!,
        style: const TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.w800,
        ),
      ),
      const SizedBox(height: 8.0),
      Text(
        '$length | $genres',
        style: const TextStyle(
          fontSize: 12.0,
          fontWeight: FontWeight.w600,
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final content = <Widget>[
      ..._buildTitleAndLengthInMinutes(),
    ];

    if (event.directors?.isNotEmpty() ?? false) {
      content.add(
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: _DirectorInfo(director: event.director!),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: content,
    );
  }
}

class _DirectorInfo extends StatelessWidget {
  const _DirectorInfo({required this.director});

  final String director;

  @override
  Widget build(BuildContext context) {
    final messages = MessageProvider.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${messages.director}:',
          style: const TextStyle(
            fontSize: 12.0,
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 4.0),
        Expanded(
          child: Text(
            director,
            style: const TextStyle(
              fontSize: 12.0,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}
