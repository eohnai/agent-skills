# Output examples

Everything below is fictional: the project, files, functions, and evidence. When running the skill, replace them with what you actually found. Never copy these conclusions.

The fictional project is a group-project web app with a React frontend (`web/`) and a Flask backend (`api/`).

## Several items: rebuilding full issues from short comments

Input (PR review comments from a teammate): "#2 old search results overwrite new ones?? #5 signup says success even when the welcome email fails"

Assume the investigation found: search requests aren't tied to the query that started them; `create_user` commits the user and returns 201 regardless of whether `send_welcome_email` raised; the project spec says the email is optional, but the user must be told if it failed.

| # | What's happening | Root cause | Recommendation | Evidence | Where to change |
|---|---|---|---|---|---|
| #2 | A user types "cat", then quickly changes it to "car". The "cat" request is slower and finishes last, so the results list shows cat results under the search box that says "car". | Each response is written to the results list when it arrives, with no check that it still matches the current query. Whichever request finishes last wins, regardless of which was sent last. | Tag each request with the query (or an incrementing request number) and ignore any response whose tag no longer matches the current one. This fixes the bug without slowing typing down. Verify by throttling the network in dev tools and typing quickly: the list must always match the box. | Verified in code: `handleResults` in `web/src/Search.jsx:48` calls `setResults` unconditionally. Inferred: the bug needs a slow request, which is why it's hard to reproduce locally. The project already does this correctly in `useProfile`, which compares a request id before setting state, so the pattern is reusable. | `web/src/Search.jsx`: ① `runSearch`: store the request number before calling `fetch`. ② `handleResults`: drop the response if its number isn't the latest. |
| #5 | When the email service is down, signup still shows "Welcome! Check your email", but no email arrives, and the user waits for it. | The endpoint treats "user created" and "email sent" as one success, but they can fail independently. The spec allows signup without the email; it just requires telling the user. | Keep creating the account, but return whether the email was sent (e.g. `"email_sent": false`) and have the frontend show "Account created; we couldn't send the welcome email" in that case. Don't roll back the account; the spec says the email is optional. Verify with the email client mocked to raise. | Verified in code: `create_user` in `api/routes/auth.py:31` wraps `send_welcome_email` in a bare `try/except: pass` and always returns 201. Docs say: `docs/specs/signup.md` requires a visible message when the email fails. | ① `api/routes/auth.py` `create_user`: catch the email error, log it, and include `email_sent` in the response. ② `web/src/Signup.jsx` `onSuccess`: show the fallback message when `email_sent` is false. |

Note how "Root cause" explains *why*, "Evidence" says what the code shows and how sure we are, and "Where to change" names exact functions. None of them repeat the "What's happening" column.

## One item: the same fields, in depth

Input: "TA feedback: 'Search results are sometimes wrong.' Why, and what should we change?"

**#:** 1

**What's happening:** Search sometimes shows results for an earlier query. For example, a user types "cat" and then quickly changes it to "car". Two requests go out. If the "cat" request takes longer, it arrives after the "car" results and replaces them. The box says "car", but the list shows cats. The TA saw a symptom that only appears when one request is slower than the next, which is why it seems random.

**Root cause:** The results list has no idea which query a response belongs to. `handleResults` writes whatever arrives into the list, so the last response to arrive wins, not the last request sent.

Making the user wait for each search before typing again (or debouncing heavily) would hide the problem most of the time, but it slows everyone down and still fails on a slow network. The real fix is to make responses prove they're still current.

**Recommendation:** Give each search request a number, remember the latest number, and when a response arrives, only apply it if its number is still the latest. Older responses are simply ignored.

This keeps typing fast and works however slow the network is. Comparing the query text instead of a number also works, but breaks if the user goes "car" → "cat" → "car", so the number is safer.

To verify: in the browser dev tools, throttle the network to "Slow 3G", type a few queries quickly, and confirm the list always matches the box. Also confirm a normal single search still shows its results. Note that this is a reading of the code, not a test run: **not verified** until you do that check.

**Evidence:** Verified in code: `handleResults` (`web/src/Search.jsx:48`) calls `setResults(data)` with no check. `runSearch` (`web/src/Search.jsx:30`) sends the request but doesn't record anything about it. The project already solves this in `useProfile` (`web/src/hooks/useProfile.js:12`), which compares a request id before updating state, so the team has a working pattern to copy.

**Where to change:** `web/src/Search.jsx`:

- `runSearch`: increment a `latestRequest` ref and pass the number along with the request.
- `handleResults`: return early if the response's number isn't `latestRequest`.

## Non-code issues and missing evidence

The same six fields work for process or design questions. In "Where to change", name the document, setting, or process step (for example, "README setup section" or "the team's PR checklist"). For a pure concept question, write "Nothing to change; this is a conceptual explanation."

If the input is too vague to pin down (for example, "this isn't compatible"), ask what it should be compatible with. If you can explain part of it but can't read a key source (say, the external API's documentation), give the verified part and state in "Recommendation" exactly what evidence is still needed to decide.
