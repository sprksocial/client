import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// The shared Spark symbols. Directional variants reuse their source artwork.
enum AppIconData {
  addPostFilled('add_post_filled.svg'),
  addUser('add_user.svg'),
  add('add.svg'),
  arrowRight('arrow_right.svg'),
  arrowFlip('arrow_flip.svg'),
  at('at.svg'),
  attach('attach.svg'),
  bookmarkFilled('bookmark_filled.svg'),
  bookmarkOutline('bookmark_outline.svg'),
  camera('camera.svg'),
  cancel('cancel.svg'),
  chevronDown('chevron_down.svg'),
  chevronLeft('chevronleft.svg'),
  colors('colors.svg'),
  comment('comment.svg'),
  commentFilled('comment_filled.svg'),
  disk('disk.svg'),
  eyeMin('eye_min.svg'),
  filters('filters.svg'),
  folderMini('folder_mini.svg'),
  gallery('gallery.svg'),
  grid('grid.svg'),
  gridFilled('grid_filled.svg'),
  hashtag('hashtag.svg'),
  home('home.svg'),
  homeFilled('home_filled.svg'),
  less('less.svg'),
  like('like.svg'),
  likeFilled('like_filled.svg'),
  likeMini('like_mini.svg'),
  link('link.svg'),
  messagesFilled('messages_filled.svg'),
  micro('micro.svg'),
  more('more.svg'),
  moreHoriz('more_horiz.svg'),
  music('music.svg'),
  explore('explore.svg'),
  exploreFilled('explore_filled.svg'),
  messages('messages.svg'),
  navbarPost('navbar_post.svg'),
  navbarPostFilled('navbar_post_filled.svg'),
  pin('pin.svg'),
  play('play.svg'),
  plusFilled('plus_filled.svg'),
  plus('plus.svg'),
  profileLiked('profile_liked.svg'),
  profileTagged('profile_tagged.svg'),
  repost('repost.svg'),
  repostLarge('repost_large.svg'),
  search('search.svg'),
  send('send.svg'),
  share('share.svg'),
  smiley('smiley.svg'),
  tag('tag.svg'),
  typo('typo.svg'),
  verified('verified.svg'),
  volume('volume.svg'),
  match('match.svg'),
  sideShare('share.svg'),
  gear('gear.svg'),
  warning('warning.svg'),
  offline('offline.svg'),
  person('person.svg'),
  people('people.svg'),
  notifications('notifications.svg'),
  delete('delete.svg'),
  block('block.svg'),
  check('check.svg'),
  history('history.svg'),
  pause('pause.svg'),
  undo('undo.svg'),
  video('video.svg'),
  mediaUnavailable('media_unavailable.svg'),
  hidden('hidden.svg'),
  edit('edit.svg'),
  sticker('sticker.svg'),
  effects('effects.svg'),
  blur('blur.svg'),
  crop('crop.svg'),
  layersForward('layers_forward.svg'),
  waveform('waveform.svg'),
  volumeOff('volume_off.svg'),
  drag('drag.svg'),
  move('move.svg'),
  selectionSingle('selection_single.svg'),
  alignLeft('align_left.svg'),
  alignCenter('align_center.svg'),
  alignRight('align_left.svg', mirror: true),
  circle('circle.svg'),
  rectangleFilled('rectangle_filled.svg'),
  eraser('eraser.svg'),
  rotate('rotate.svg'),
  shield('shield.svg'),
  externalLink('external_link.svg'),
  document('document.svg'),
  signOut('sign_out.svg'),
  key('key.svg'),
  redo('undo.svg', mirror: true),
  layersBackward('layers_forward.svg', quarterTurns: 2),
  chevronRight('chevronleft.svg', quarterTurns: 2),
  chevronUp('chevron_down.svg', quarterTurns: 2),
  arrowBack('arrow_right.svg', mirror: true);

  const AppIconData(
    String fileName, {
    this.quarterTurns = 0,
    this.mirror = false,
  }) : assetPath = 'icons/$fileName';

  final String assetPath;
  final int quarterTurns;
  final bool mirror;
}

/// A Spark symbol that inherits the surrounding [IconTheme].
class AppIcon extends StatelessWidget {
  const AppIcon(
    this.icon, {
    super.key,
    this.size,
    this.color,
    this.semanticLabel,
  });

  final AppIconData icon;
  final double? size;
  final Color? color;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = IconTheme.of(context);
    final effectiveSize = size ?? theme.size ?? 24;
    final effectiveColor = color ?? theme.color ?? const Color(0xFF000000);
    final opacity = theme.opacity ?? 1;
    Widget picture = SvgPicture.asset(
      icon.assetPath,
      package: 'assets',
      width: effectiveSize,
      height: effectiveSize,
      colorFilter: ColorFilter.mode(
        effectiveColor.withValues(alpha: effectiveColor.a * opacity),
        BlendMode.srcIn,
      ),
      semanticsLabel: semanticLabel,
      excludeFromSemantics: semanticLabel == null,
    );
    if (icon.quarterTurns != 0) {
      picture = RotatedBox(quarterTurns: icon.quarterTurns, child: picture);
    }
    if (icon.mirror) {
      picture = Transform.flip(flipX: true, child: picture);
    }
    return SizedBox.square(
      dimension: effectiveSize,
      child: Center(child: picture),
    );
  }
}

/// Existing factories preserve the original artwork colors when no tint is set.
class AppIcons {
  static Widget _asset(
    AppIconData icon, {
    required double size,
    Color? color,
  }) => SvgPicture.asset(
    icon.assetPath,
    width: size,
    height: size,
    colorFilter: color == null
        ? null
        : ColorFilter.mode(color, BlendMode.srcIn),
    package: 'assets',
  );

  static Widget addPostFilled({double size = 24, Color? color}) =>
      _asset(AppIconData.addPostFilled, size: size, color: color);

  static Widget addUser({double size = 24, Color? color}) =>
      _asset(AppIconData.addUser, size: size, color: color);

  static Widget add({double size = 24, Color? color}) =>
      _asset(AppIconData.add, size: size, color: color);

  static Widget arrowRight({double size = 24, Color? color}) =>
      _asset(AppIconData.arrowRight, size: size, color: color);

  static Widget arrowFlip({double size = 24, Color? color}) =>
      _asset(AppIconData.arrowFlip, size: size, color: color);

  static Widget at({double size = 24, Color? color}) =>
      _asset(AppIconData.at, size: size, color: color);

  static Widget attach({double size = 24, Color? color}) =>
      _asset(AppIconData.attach, size: size, color: color);

  static Widget bookmarkFilled({double size = 24, Color? color}) =>
      _asset(AppIconData.bookmarkFilled, size: size, color: color);

  static Widget bookmarkOutline({double size = 24, Color? color}) =>
      _asset(AppIconData.bookmarkOutline, size: size, color: color);

  static Widget camera({double size = 24, Color? color}) =>
      _asset(AppIconData.camera, size: size, color: color);

  static Widget cancel({double size = 24, Color? color}) =>
      _asset(AppIconData.cancel, size: size, color: color);

  static Widget chevronDown({double size = 24, Color? color}) =>
      _asset(AppIconData.chevronDown, size: size, color: color);

  static Widget chevronleft({double size = 24, Color? color}) =>
      _asset(AppIconData.chevronLeft, size: size, color: color);

  static Widget colors({double size = 24, Color? color}) =>
      _asset(AppIconData.colors, size: size, color: color);

  static Widget comment({double size = 24, Color? color}) =>
      _asset(AppIconData.comment, size: size, color: color);

  static Widget commentFilled({double size = 24, Color? color}) =>
      _asset(AppIconData.commentFilled, size: size, color: color);

  static Widget disk({double size = 24, Color? color}) =>
      _asset(AppIconData.disk, size: size, color: color);

  static Widget eyeMin({double size = 24, Color? color}) =>
      _asset(AppIconData.eyeMin, size: size, color: color);

  static Widget filters({double size = 24, Color? color}) =>
      _asset(AppIconData.filters, size: size, color: color);

  static Widget folderMini({double size = 24, Color? color}) =>
      _asset(AppIconData.folderMini, size: size, color: color);

  static Widget gallery({double size = 24, Color? color}) =>
      _asset(AppIconData.gallery, size: size, color: color);

  static Widget grid({double size = 24, Color? color}) =>
      _asset(AppIconData.grid, size: size, color: color);

  static Widget gridFilled({double size = 24, Color? color}) =>
      _asset(AppIconData.gridFilled, size: size, color: color);

  static Widget hashtag({double size = 24, Color? color}) =>
      _asset(AppIconData.hashtag, size: size, color: color);

  static Widget home({double size = 24, Color? color}) =>
      _asset(AppIconData.home, size: size, color: color);

  static Widget homeFilled({double size = 24, Color? color}) =>
      _asset(AppIconData.homeFilled, size: size, color: color);

  static Widget less({double size = 24, Color? color}) =>
      _asset(AppIconData.less, size: size, color: color);

  static Widget like({double size = 24, Color? color}) =>
      _asset(AppIconData.like, size: size, color: color);

  static Widget likeFilled({double size = 24, Color? color}) =>
      _asset(AppIconData.likeFilled, size: size, color: color);

  static Widget likeMini({double size = 24, Color? color}) =>
      _asset(AppIconData.likeMini, size: size, color: color);

  static Widget link({double size = 24, Color? color}) =>
      _asset(AppIconData.link, size: size, color: color);

  static Widget messagesFilled({double size = 24, Color? color}) =>
      _asset(AppIconData.messagesFilled, size: size, color: color);

  static Widget micro({double size = 24, Color? color}) =>
      _asset(AppIconData.micro, size: size, color: color);

  static Widget more({double size = 24, Color? color}) =>
      _asset(AppIconData.more, size: size, color: color);

  static Widget moreHoriz({double size = 24, Color? color}) =>
      _asset(AppIconData.moreHoriz, size: size, color: color);

  static Widget music({double size = 24, Color? color}) =>
      _asset(AppIconData.music, size: size, color: color);

  static Widget explore({double size = 24, Color? color}) =>
      _asset(AppIconData.explore, size: size, color: color);

  static Widget exploreFilled({double size = 24, Color? color}) =>
      _asset(AppIconData.exploreFilled, size: size, color: color);

  static Widget messages({double size = 24, Color? color}) =>
      _asset(AppIconData.messages, size: size, color: color);

  static Widget navbarPost({double size = 24, Color? color}) =>
      _asset(AppIconData.navbarPost, size: size, color: color);

  static Widget navbarPostFilled({double size = 24, Color? color}) =>
      _asset(AppIconData.navbarPostFilled, size: size, color: color);

  static Widget pin({double size = 24, Color? color}) =>
      _asset(AppIconData.pin, size: size, color: color);

  static Widget play({double size = 24, Color? color}) =>
      _asset(AppIconData.play, size: size, color: color);

  static Widget plusFilled({double size = 24, Color? color}) =>
      _asset(AppIconData.plusFilled, size: size, color: color);

  static Widget plus({double size = 24, Color? color}) =>
      _asset(AppIconData.plus, size: size, color: color);

  static Widget profileLiked({double size = 24, Color? color}) =>
      _asset(AppIconData.profileLiked, size: size, color: color);

  static Widget profileTagged({double size = 24, Color? color}) =>
      _asset(AppIconData.profileTagged, size: size, color: color);

  static Widget repost({double size = 24, Color? color}) =>
      _asset(AppIconData.repost, size: size, color: color);

  static Widget repostLarge({double size = 24, Color? color}) =>
      _asset(AppIconData.repostLarge, size: size, color: color);

  static Widget search({double size = 24, Color? color}) =>
      _asset(AppIconData.search, size: size, color: color);

  static Widget send({double size = 24, Color? color}) =>
      _asset(AppIconData.send, size: size, color: color);

  static Widget share({double size = 24, Color? color}) =>
      _asset(AppIconData.share, size: size, color: color);

  static Widget smiley({double size = 24, Color? color}) =>
      _asset(AppIconData.smiley, size: size, color: color);

  static Widget tag({double size = 24, Color? color}) =>
      _asset(AppIconData.tag, size: size, color: color);

  static Widget typo({double size = 24, Color? color}) =>
      _asset(AppIconData.typo, size: size, color: color);

  static Widget verified({double size = 24, Color? color}) =>
      _asset(AppIconData.verified, size: size, color: color);

  static Widget volume({double size = 24, Color? color}) =>
      _asset(AppIconData.volume, size: size, color: color);

  static Widget match({double size = 24, Color? color}) =>
      _asset(AppIconData.match, size: size, color: color);

  static Widget sideShare({double size = 24, Color? color}) =>
      _asset(AppIconData.sideShare, size: size, color: color);

  static Widget gear({double size = 24, Color? color}) =>
      _asset(AppIconData.gear, size: size, color: color);
}
