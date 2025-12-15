import Foundation

enum EducationTopicsStrategy {
    static let topics: [EducationTopic] = [
        EducationTopic(
            id: "archetypes",
            title: "Artist Archetypes",
            category: "Strategy",
            summary: "Six common artist archetypes, how they grow, earn, and the trade-offs to expect.",
            body: """
Artist Archetypes (pick a primary and secondary)
Use this to choose the game you are playing. Combine one main lane with one supporting lane; you can evolve later.

Artist-Entrepreneur
- Identity: treats music as an owned asset and builds systems around it.
- Growth: consistent releases, funnels, brand adjacency, long-term compounding.
- Money mix: owned masters, publishing, direct fan offers, products or services.
- Strengths: sustainable, high ownership, low reliance on hype.
- Watch-outs: slower validation, fewer industry cosigns, requires discipline.
- Best for: people comfortable building quietly and stacking leverage.

Culture Driver
- Identity: shapes aesthetics, language, and energy; trend-setter.
- Growth: social virality, community momentum, collaborations.
- Money mix: brand deals, touring, streaming spikes, merch.
- Strengths: fast reach, strong fan identity, high visibility.
- Watch-outs: volatile income, pressure to stay relevant, burnout risk.
- Best for: charismatic artists who enjoy constant sharing.

Craft Purist
- Identity: art-first, quality over quantity.
- Growth: slow burn, reputation, word of mouth, critical respect.
- Money mix: albums, vinyl, selective sync, premium opportunities.
- Strengths: deep respect, longevity, timeless catalog.
- Watch-outs: smaller audience, inconsistent cash flow, under-monetized.
- Best for: artists willing to trade speed for depth.

Niche Specialist
- Identity: serves one clear mood, activity, or identity.
- Growth: algorithmic discovery, playlists, repeat listening.
- Money mix: streaming, sync, licensing, high lifetime value per listener.
- Strengths: predictable growth, strong retention, low competition.
- Watch-outs: limited mainstream appeal, creative boredom risk.
- Best for: disciplined artists who can deliver consistency.

Collaborator / Network Builder
- Identity: relationships-first; thrives in rooms and features.
- Growth: cross-pollination, guest spots, co-writing, proximity to teams.
- Money mix: splits, advances, session work, touring.
- Strengths: access, opportunity flow, fast learning.
- Watch-outs: diluted ownership, dependency on others, identity drift.
- Best for: social artists with clear boundaries on splits and credits.

Sync and Utility Artist
- Identity: music built to support media or brands.
- Growth: placements via libraries, supervisors, and briefs.
- Money mix: sync fees, backend royalties, catalog licensing.
- Strengths: revenue without fame, scalable, low public pressure.
- Watch-outs: less fan recognition, creative constraints, metadata overhead.
- Best for: privacy-focused artists who like clear briefs and predictable revenue.
"""
        ),
        EducationTopic(
            id: "growth",
            title: "Growth",
            category: "Strategy",
            summary: "Ten growth approaches with what to do, success signals, and common mistakes.",
            body: """
Growth Playbook (pair one primary with one support tactic)
Pick one core lane and one supporting lane. Clarity beats trying to do everything.

Catalog-First Compounding
- What it is: treat each song as an asset that lifts the whole catalog.
- Do this: batch 6-12 songs, release every 4-8 weeks, refresh older songs when new ones drop.
- Signals: monthly listeners rise steadily; old songs keep getting saves; streams do not crash between releases.
- Watch-outs: perfectionism delays; metadata sloppiness undercuts compounding.
- Best for: disciplined releasers and indie owners.

Niche Dominance
- What it is: own a single mood, use case, or identity so algorithms know where to place you.
- Do this: align sound, visuals, titles, and content language to one lane; resist genre-hopping early.
- Signals: high save/stream ratio; fans describe you the same way; playlists slot you consistently.
- Watch-outs: boredom leading to off-brand releases; drifting into generic sounds.
- Best for: artists comfortable with focus and repetition.

Content-to-Song Loop
- What it is: content angles push listeners into one song repeatedly.
- Do this: pick 1-2 repeatable formats (POV, lyric moment, story) and reuse the same song with new angles.
- Signals: comments mention the song; saves spike after posts; sound usage grows.
- Watch-outs: random posts with no song CTA; switching songs too soon.
- Best for: artists already posting consistently.

Collaboration-as-Distribution
- What it is: features and co-releases to borrow audiences, not validation.
- Do this: target peers with similar size and vibe; cross-post; coordinate release timing.
- Signals: new followers actually stream; repeat listeners from new regions; follow-up collabs invited.
- Watch-outs: trading ownership for clout; unclear splits.
- Best for: relational artists and producers.

Playlist and Algorithm Leverage
- What it is: let listener behavior and playlists carry the song.
- Do this: optimize for saves/repeats; pitch editorial; seed light traffic; title and tag cleanly.
- Signals: algorithmic playlists trigger; streams hold after playlist removal; song resurfaces weeks later.
- Watch-outs: making playlists the strategy instead of the catalyst.
- Best for: songs with a strong first-10-second hook.

Direct Fan Funnel
- What it is: convert listeners to contacts you own.
- Do this: offer early access or exclusives; collect email/SMS; launch to fans before DSPs.
- Signals: predictable release spikes; quick replies; fewer posts needed to activate listeners.
- Watch-outs: building too early without a hook; never starting at all.
- Best for: community-minded artists.

Sync and Licensing Focus
- What it is: placements as primary growth and revenue.
- Do this: produce clear-emotion, clean-lyric versions; manage stems and metadata; submit intentionally.
- Signals: placement emails; backend royalties; repeat briefs from supervisors.
- Watch-outs: accidental samples; vague ownership; spamming libraries without fit.
- Best for: cinematic, mood-based, or brand-safe artists.

Controlled Paid Growth
- What it is: ads amplify proven signals, not create them.
- Do this: boost winning posts; target lookalikes; track cost per save and follower; kill losers quickly.
- Signals: cost per save drops; organic picks up; ads become optional.
- Watch-outs: paying to cover weak music or positioning; no measurement.
- Best for: data-comfortable artists with a working song.

Brand-Adjacent Growth
- What it is: music reinforces a bigger ecosystem (products, content series, tools).
- Do this: tie songs to launches; reuse music across platforms; collaborate with brand partners.
- Signals: fans discover music through the brand; multiple income streams feed each other.
- Watch-outs: brand overshadows music; unclear storytelling.
- Best for: creators with something else to sell or say.

Slow Burn / Reputation
- What it is: fewer releases with more weight and polish.
- Do this: tease instead of flood; release when ready; make the drop an event.
- Signals: strong week-one performance; industry inbound; fans wait instead of forget.
- Watch-outs: silence without momentum; perfectionism paralysis.
- Best for: artists with existing demand or critical respect.
"""
        ),
        EducationTopic(
            id: "monetization-paths",
            title: "Monetization Paths",
            category: "Strategy",
            summary: "Revenue lanes beyond streaming and how to pick a primary and secondary path.",
            body: """
Monetization Paths (Beyond Just Streaming)
Most indie artists do not need more listeners; they need a clearer path to revenue.

Path 1: Streaming plus Catalog Compounding
Best for consistent releasers and niche specialists.
- Release often.
- Build a long-tail catalog.
- Focus on saves and repeats.
Pros: scalable and low-touch. Cons: slower at first.

Path 2: Direct-to-Fan (Email or SMS plus Sales)
Best for artists with tight communities.
- Bandcamp sales.
- Merch.
- Patreon.
- Exclusive drops.
Pros: high revenue per fan. Cons: requires relationship building.

Path 3: Sync and Licensing
Best for cinematic, mood-based, or brand-safe music.
- Placements in TV, film, games, and ads.
- Upfront fees plus backend royalties.
Pros: revenue without fame. Cons: requires metadata, clear rights, and patience.

Path 4: Services plus Music (Hybrid)
Best for producers, engineers, and writers.
- Production services.
- Mixing or mastering.
- Writing sessions.
- Teaching.
Pros: immediate cash flow. Cons: can distract from artist brand if unmanaged.

Path 5: Brand Partnerships
Best for content-native artists with cultural presence.
- Sponsorships.
- Brand campaigns.
- UGC deals.
Pros: large checks possible. Cons: depends on public presence.

Choosing a Path (Simple Rules)
- Privacy plus profit: sync, catalog, and direct-to-fan.
- Fast growth: content loops and brand partnerships.
- Stability: direct-to-fan and services.
- Long-term wealth: ownership and catalog compounding.
"""
        )
    ]
}
