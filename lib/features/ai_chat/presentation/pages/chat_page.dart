import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:egy/app/localization/generated/app_localizations.dart';
import 'package:egy/app/router/route_names.dart';
import 'package:egy/app/theme/app_colors.dart';
import 'package:egy/core/widgets/authenticated_scaffold.dart';
import 'package:egy/core/widgets/ai/ai_feedback.dart';
import 'package:egy/core/widgets/content_fade.dart';
import 'package:egy/features/properties/presentation/widgets/listing_card.dart';
import '../cubit/chat_cubit.dart';
import '../widgets/chat_typing_indicator.dart';

/// Opening this screen never makes a provider request.
class ChatPage extends StatefulWidget {
  const ChatPage({super.key});
  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _text = TextEditingController();
  final _scroll = ScrollController();
  @override
  void dispose() {
    _text.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _send() {
    final text = _text.text.trim();
    if (text.isEmpty || text.length > 4000) {
      return;
    }
    context.read<ChatCubit>().send(text);
    _text.clear();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final cubit = context.read<ChatCubit>();
    return AuthenticatedScaffold(
      title: l.aiChat,
      subtitle: l.aiChatSubtitle,
      actions: [
        IconButton(
          key: const Key('chat_reset'),
          tooltip: l.aiNewChat,
          onPressed: cubit.reset,
          icon: const Icon(Icons.add_comment_outlined),
        ),
      ],
      child: BlocConsumer<ChatCubit, ChatState>(
        listener: (context, state) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && _scroll.hasClients) {
              if (MediaQuery.disableAnimationsOf(context)) {
                _scroll.jumpTo(_scroll.position.maxScrollExtent);
                return;
              }
              _scroll.animateTo(
                _scroll.position.maxScrollExtent,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
              );
            }
          });
        },
        builder: (context, state) {
          final ready = state as ChatReady;
          return Column(
            children: [
              Expanded(
                child: ListView(
                  controller: _scroll,
                  padding: const EdgeInsets.all(24),
                  children: [
                    if (ready.messages.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          l.aiChatWelcome,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                    for (final message in ready.messages)
                      ContentFadeIn(
                        key: ObjectKey(message),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Align(
                              alignment: message.isUser
                                  ? AlignmentDirectional.centerEnd
                                  : AlignmentDirectional.centerStart,
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: message.isUser
                                      ? AppColors.primaryNavy
                                      : Theme.of(context).colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: SelectableText(
                                  message.text,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: message.isUser
                                            ? AppColors.white
                                            : Theme.of(context).colorScheme.onSurface,
                                      ),
                                ),
                              ),
                            ),
                            for (final property
                                in message.response?.properties ?? [])
                              ListingCard(
                                property: property,
                                onSimilar: () => context.pushNamed(
                                  RouteNames.recommendationResults,
                                  queryParameters: {
                                    'similar': '${property.id}',
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
                    if (ready.messages.isNotEmpty && !ready.sending)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final suggestion
                              in ready.messages.last.response?.suggestions ??
                                  <String>[])
                            ActionChip(
                              label: Text(suggestion),
                              onPressed: () => cubit.send(suggestion),
                            ),
                        ],
                      ),
                    if (ready.sending) ChatTypingIndicator(label: l.aiThinking),
                    if (ready.failure != null)
                      AiFeedback(failure: ready.failure!, onRetry: cubit.retry),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        key: const Key('chat_input'),
                        controller: _text,
                        enabled: !ready.sending && !ready.loading,
                        maxLength: 4000,
                        minLines: 1,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: l.aiMessageHint,
                          counterText: '',
                        ),
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _send(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      key: const Key('chat_send'),
                      tooltip: l.aiSend,
                      onPressed: ready.sending || ready.loading ? null : _send,
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.primaryGold,
                      ),
                      icon: const Icon(
                        Icons.send_rounded,
                        color: AppColors.primaryNavy,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
