import 'package:auto_route/auto_route.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


// @RoutePage() TODO
class CommentsTray extends ConsumerStatefulWidget {
  final String postUri;
  final String postCid;
  final int commentCount;
  final bool isSprk;

  const CommentsTray({super.key, required this.postUri, required this.postCid, required this.commentCount, required this.isSprk});

  @override
  ConsumerState<CommentsTray> createState() => _CommentsTrayState();
}

class _CommentsTrayState extends ConsumerState<CommentsTray> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();


  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _animation = CurvedAnimation(parent: _animationController, curve: Curves.easeOut);
    _animationController.forward();

    // Add focus listener to scroll to bottom when comment field receives focus
    _focusNode.addListener(_focusListener);

    
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    _focusNode.removeListener(_focusListener);
    _focusNode.dispose();
    super.dispose();
  }

  void _focusListener() {
    if (_focusNode.hasFocus) {
      // When the text field gets focus, ensure it's visible
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    }
  }

  void _closeComments() {
    _animationController.reverse().then((_) {
      context.router.maybePop();
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // final state = ref.watch(
    //   commentsTrayProvider(
    //     postUri: widget.postUri,
    //     postCid: widget.postCid,
    //     isSprk: widget.isSprk,
    //     commentCount: widget.commentCount,
    //   ),
    // );
    final height = MediaQuery.of(context).size.height * 0.75;
    final backgroundColor = Theme.of(context).colorScheme.surface;
    final borderColor = Theme.of(context).colorScheme.outline;
    final textColor = Theme.of(context).colorScheme.onSurface;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    // final loadComments = ref.watch(
    //   loadCommentsProvider(
    //     postUri: widget.postUri,
    //     postCid: widget.postCid,
    //     isSprk: widget.isSprk,
    //   ),
    // );


    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(offset: Offset(0, height * (1 - _animation.value)), child: child);
      },
      child: SafeArea(
        child: Container(
          height: height,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
            border: Border.all(color: Theme.of(context).colorScheme.outline.withAlpha(128)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(border: Border(bottom: BorderSide(color: borderColor, width: 0.5))),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(color: borderColor, borderRadius: BorderRadius.circular(2)),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            //'${state.commentCount} comments',
                            'Working on it...',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
                          ),
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: _closeComments,
                            icon: Icon(FluentIcons.dismiss_24_regular, color: textColor),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Placeholder(),
              //   child: loadComments.when(
              //     data: (comments) {
              //       return ListView.builder(
              //         controller: _scrollController,
              //         padding: const EdgeInsets.only(bottom: 16),
              //         itemCount: comments.length,
              //         itemBuilder: (context, index) {
              //           final comment = comments[index];
              //           return CommentItem(
              //             key: ValueKey('comment-${comment.id}'),
              //             comment: comment,
              //             parentPostUri: widget.postUri,
              //             parentPostCid: widget.postCid,
              //           );
              //         },
              //       );
              //     },
              //     error: (error, stackTrace) {
              //       return Center(child: Text('Error: $error'));
              //     },
              //     loading: () {
              //       return const Center(child: CircularProgressIndicator());
              //     },
              //   ),
              // ),
              // Padding(
              //   padding: EdgeInsets.only(bottom: keyboardHeight),
              //   child: CommentInputWidget(
              //     videoId: widget.postUri,
              //     postCid: widget.postCid,
              //     postUri: widget.postUri,
              //     isSprk: widget.isSprk,
              //     focusNode: _focusNode,
              //   ),
              // ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
