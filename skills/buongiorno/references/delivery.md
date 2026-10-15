# Delivery options

Pick what the user already has, preferring the **narrowest credential**: a Telegram bot
token can only control that bot, and an email API key (Resend, Postmark, SendGrid) can be
limited to sending. A Gmail app password unlocks the whole mailbox, so it comes last.
There is no "right" provider: Buongiorno's original setup used SendGrid only because its
author already had an account.

In every case: the user creates the key or token themselves and types it into the
environment settings (below). Never ask them to paste it in chat, and the routine must
never print it.

All snippets use Python's standard library (`urllib.request`, `smtplib`), so the routine
needs no installs.

## Where secrets go (explain this plainly)

1. In claude.ai/code, create a **new cloud environment just for this newsletter** (e.g.
   "Buongiorno") and select it when creating the routine. Don't use "Default": every cloud
   session started in an environment can read its variables, so a key in "Default" is
   exposed to everything else the user does in the cloud.
2. In that environment's settings, add each secret as an environment variable (for
   example `TELEGRAM_BOT_TOKEN` and `TELEGRAM_CHAT_ID`). The routine reads them when it
   runs; they are never written into the prompt or the chat.
3. Network access: set it as narrowly as the platform allows. If it supports a list of
   allowed domains, add exactly the feed hosts you tested, `news.google.com`, the data
   APIs, the delivery host (e.g. `api.telegram.org`) and the git host. Use full access only
   if no allowlist exists, and tell the user in one plain sentence that full access means a
   misbehaving run could reach any website. (With an allowlist, reading article pages or
   searching unknown event sites may fail; the prompt already copes with that.)

**How to stop it later:** delete the routine, delete its cloud environment, and revoke the
key (delete the bot via @BotFather `/deletebot`, delete the API key, or delete the Gmail
app password).

## Telegram, step by step (good for phone-first users)

Plain explanation first: "Telegram lets a small program (a 'bot') send you messages. We'll
create your own bot; only you will talk to it."

1. In Telegram, search for **@BotFather** (the one with the blue tick) and press Start.
2. Send `/newbot`, choose a display name (e.g. "My morning news") and a username ending in
   `bot` (e.g. `anna_morning_bot`). BotFather replies with a **token** (a long code with
   a colon). Keep it private: don't paste it in this chat.
3. Open your new bot (BotFather gives a link) and press **Start**, then send it any
   message ("hi"). Bots can only message people who started them.
4. Find your **chat id**. On a computer, open
   `https://api.telegram.org/bot<TOKEN>/getUpdates` in a browser (replace `<TOKEN>` with
   the token; don't share this link, it contains the secret). Look for `"chat":{"id":`
   followed by a number: that's the chat id. If the page shows `"result":[]`, send the bot
   another message and reload.
5. Add two environment variables in the newsletter's environment: `TELEGRAM_BOT_TOKEN` and
   `TELEGRAM_CHAT_ID`.

Sending: `POST https://api.telegram.org/bot<token>/sendMessage` with `chat_id`, `text`,
`parse_mode:"HTML"`, `disable_web_page_preview:true`. Max 4,096 characters per message:
group sections into as few messages as fit (keep each section whole), usually 4-6 per day.
Only `<b>`, `<i>`, `<a href>` are allowed; escape all fetched text with
`html.escape(..., quote=True)`. The token is part of the URL path, so never print the URL
or the request.

## Email

| Provider | Env var(s) | Endpoint | Notes |
|---|---|---|---|
| Resend | `RESEND_API_KEY` | `POST https://api.resend.com/emails`, `Authorization: Bearer <key>`, JSON `{from:"Name <addr>", to:[addr], subject, html, text}` | Send-only key; free tier; verify a domain. Success = HTTP 200. Good default for email. |
| Postmark | `POSTMARK_SERVER_TOKEN` | `POST https://api.postmarkapp.com/email`, header `X-Postmark-Server-Token`, JSON `{From, To, Subject, HtmlBody, TextBody, MessageStream:"outbound"}` | Very good deliverability. |
| SendGrid | `SENDGRID_API_KEY` | `POST https://api.sendgrid.com/v3/mail/send`, `Authorization: Bearer <key>`, JSON `{personalizations:[{to:[{email}]}], from:{email,name}, subject, content:[{type:"text/plain",value},{type:"text/html",value}]}` | Key with only "Mail Send" permission. Success = HTTP 202. Sender must be verified. |
| Mailgun | `MAILGUN_API_KEY`, `MAILGUN_DOMAIN` | `POST https://api.mailgun.net/v3/<domain>/messages`, basic auth `api:<key>`, form fields `from,to,subject,text,html` | EU accounts use `api.eu.mailgun.net`. |
| Gmail (SMTP) | `GMAIL_USER`, `GMAIL_APP_PASSWORD` | `smtplib.SMTP_SSL("smtp.gmail.com", 465)`, an `email.message.EmailMessage` with text + HTML alternatives | Last choice: see the warning below. |

Deliverability tips:
- Don't send "from" a gmail.com/outlook.com address through a third-party provider; it
  fails DMARC and lands in spam. Use a domain they own, or Gmail SMTP to themselves.
- The first emails may land in spam or "Promotions": ask the user to move one to the inbox.
- Gmail clips HTML over ~100 KB behind "View entire message". If the newsletter gets close,
  split it into two emails rather than cutting content.

## Gmail, step by step (only if they really want Gmail)

**Warning to give the user:** a Gmail app password opens the whole account (it can read all
mail, not only send). The safest way is a **separate Gmail account used only to send the
newsletter** to their real address. Otherwise prefer Telegram or Resend.

1. **Turn on 2-Step Verification** on the sending Google account:
   https://myaccount.google.com/security → "2-Step Verification".
2. **Create an app password**: https://myaccount.google.com/apppasswords. Name it e.g.
   "Morning newsletter" and copy the 16-character password (shown once; spaces don't matter).
   - Page missing or "not available"? Usually 2-Step Verification is off, it's a work or
     school account whose admin blocks app passwords, or Advanced Protection is on. Use
     Telegram or Resend instead.
3. Add `GMAIL_USER` (the full sending address) and `GMAIL_APP_PASSWORD` to the newsletter's
   environment.
4. The routine sends over `smtp.gmail.com:465` to the fixed recipient.

To stop it later, delete the app password at the same page.

Outlook / Hotmail: Microsoft is phasing out password-based sending for personal accounts,
so recommend Telegram or Resend instead of SMTP.

## Slack and Discord

| Channel | Env var | How | Notes |
|---|---|---|---|
| Slack | `SLACK_WEBHOOK_URL` | `POST` JSON `{text}` or Block Kit `{blocks:[...]}` to the incoming webhook | Escape `&`, `<`, `>` in fetched text. |
| Discord | `DISCORD_WEBHOOK_URL` | `POST` JSON `{content}` (max 2,000 chars) or `{embeds:[...]}`, with `allowed_mentions:{parse:[]}` so fetched text can't ping anyone | Split long messages. |

The webhook URL is the secret: never print it.

For chat channels, replace the prompt's HTML render step with the compact text layout
described in the template, and show the user those messages as the Step 4 sample.
