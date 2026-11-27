import 'package:egy/app/localization/generated/app_localizations.dart';
import 'package:egy/app/theme/app_colors.dart';
import 'package:egy/core/web/web_breakpoints.dart';
import 'package:egy/core/web/web_property_card.dart';
import 'package:egy/core/web/web_theme.dart';
import 'package:egy/features/ai_chat/presentation/cubit/chat_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import '../widgets/web_markdown_text.dart';

/// Dedicated desktop AI Assistant workspace for Flutter Web.
class WebChatPage extends StatefulWidget {
  const WebChatPage({super.key});

  @override
  State<WebChatPage> createState() => _WebChatPageState();
}

class _WebChatPageState extends State<WebChatPage> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _send([String? overrideText]) {
    final text = (overrideText ?? _controller.text).trim();
    if (text.isEmpty) return;
    if (overrideText == null) _controller.clear();
    context.read<ChatCubit>().send(text);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: WebBreakpoints.narrowContentMaxWidth,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: WebBreakpoints.horizontalPadding(
              MediaQuery.sizeOf(context).width,
            ),
            vertical: 20,
          ),
          child: WebSurfaceCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) => Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGold.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.auto_awesome_rounded,
                            color: AppColors.primaryGold,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.aiChat,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                l10n.aiChatSubtitle,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (constraints.maxWidth < 460)
                          IconButton(
                            tooltip: l10n.aiNewChat,
                            onPressed: () => context.read<ChatCubit>().reset(),
                            icon: const Icon(Icons.add_comment_outlined),
                          )
                        else
                          OutlinedButton.icon(
                            onPressed: () => context.read<ChatCubit>().reset(),
                            icon: const Icon(
                              Icons.add_comment_outlined,
                              size: 18,
                            ),
                            label: Text(l10n.aiNewChat),
                          ),
                      ],
                    ),
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: BlocBuilder<ChatCubit, ChatState>(
                    builder: (context, state) {
                      final ready = state as ChatReady;
                      if (ready.loading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (ready.messages.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.chat_bubble_outline_rounded,
                                  size: 44,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  l10n.aiChatWelcome,
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.titleSmall,
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return ListView.separated(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(20),
                        itemCount:
                            ready.messages.length + (ready.sending ? 1 : 0),
                        separatorBuilder: (_, _) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          if (index >= ready.messages.length) {
                            return Row(
                              children: [
                                const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  l10n.aiThinking,
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            );
                          }
                          final message = ready.messages[index];
                          return _ChatBubble(
                            message: message,
                            onSuggestionTap: _send,
                            onRetryTap: () =>
                                context.read<ChatCubit>().retry(),
                          );
                        },
                      );
                    },
                  ),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: BlocBuilder<ChatCubit, ChatState>(
                    builder: (context, state) {
                      final ready = state as ChatReady;
                      return Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              enabled: !ready.sending,
                              decoration: InputDecoration(
                                hintText: l10n.aiMessageHint,
                              ),
                              onSubmitted: (_) => _send(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          FilledButton.icon(
                            onPressed: ready.sending ? null : () => _send(),
                            icon: const Icon(Icons.send_rounded, size: 18),
                            label: Text(l10n.aiSend),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({
    required this.message,
    required this.onSuggestionTap,
    required this.onRetryTap,
  });

  final ChatMessage message;
  final ValueChanged<String> onSuggestionTap;
  final VoidCallback onRetryTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isUser = message.isUser;
    final reply = message.response;
    final maxBubbleWidth = MediaQuery.sizeOf(context).width < 640
        ? MediaQuery.sizeOf(context).width * 0.85
        : 680.0;

    return Align(
      alignment:
          isUser ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxBubbleWidth),
        child: Column(
          crossAxisAlignment:
              isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser
                    ? AppColors.primaryNavy
                    : (isDark ? WebPalette.darkInput : WebPalette.lightInput),
                borderRadius: BorderRadius.circular(14),
                border: isUser
                    ? null
                    : Border.all(
                        color: scheme.outlineVariant.withValues(alpha: 0.6),
                      ),
              ),
              child: isUser
                  ? Text(
                      message.text,
                      textDirection: WebMarkdownText.isRtlText(message.text)
                          ? TextDirection.rtl
                          : TextDirection.ltr,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        height: 1.45,
                      ),
                    )
                  : WebMarkdownText(
                      text: message.text,
                      linkColor: isDark
                          ? WebPalette.darkGold
                          : AppColors.primaryNavy,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurface,
                        height: 1.5,
                      ),
                    ),
            ),
            if (message.failed) ...[
              const SizedBox(height: 6),
              TextButton.icon(
                onPressed: onRetryTap,
                icon: Icon(
                  Icons.refresh_rounded,
                  size: 16,
                  color: scheme.error,
                ),
                label: Text(
                  l10n.retryButton,
                  style: TextStyle(color: scheme.error),
                ),
              ),
            ],
            if (reply != null && reply.properties.isNotEmpty) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 328,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: reply.properties.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 14),
                  itemBuilder: (context, index) => SizedBox(
                    width: 260,
                    child: WebPropertyCard(
                      property: reply.properties[index],
                      compact: true,
                    ),
                  ),
                ),
              ),
            ],
            if (reply != null && reply.suggestions.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final s in reply.suggestions)
                    ActionChip(
                      label: Text(s),
                      onPressed: () => onSuggestionTap(s),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
