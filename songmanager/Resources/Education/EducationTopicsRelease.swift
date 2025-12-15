import Foundation

enum EducationTopicsRelease {
    static let topics: [EducationTopic] = [
        EducationTopic(
            id: "release-lifecycle",
            title: "Release Lifecycle",
            category: "Release",
            summary: "Step-by-step indie release timeline.",
            body: """
Release Lifecycle (Indie Artist Timeline)
Practical, repeatable release timeline for singles, EPs, or albums. Use it to prevent missed steps and reduce chaos. Not legal advice.

How to use this
- Pick your date, then walk each phase in order.
- Keep the same structure for every release.

Phase 0: Set Your Foundations (one-time setup)
- Accounts: distributor, PRO, MLC, SoundExchange, optional publishing admin.
- Catalog identity: consistent artist name spelling, primary genre and sub-genre, official links, press photo.

Phase 1: Lock the Song (2-8 weeks out)
- Creative lock: final structure, lyrics, production; clean versus explicit; confirm featured artists.
- Admin lock: songwriter list with legal names and PRO affiliations; producers and contributors confirmed; split agreement signed.
- Deliverables: master WAV, optional instrumental and clean, cover art (correct specs, no prohibited elements).

Phase 2: Metadata and Upload (3-6 weeks out)
- Upload: track title, artist names, featured artists, release date with time zone, ISRC, explicit flag, writers or publishers where supported, lyrics optional.
- Spotify editorial pitch: submit at least 7 days before release; earlier is better; describe mood and story honestly.

Phase 3: Pre-Release Marketing (1-4 weeks out)
- Links: smart link page, optional pre-save; verify artist profiles are correct on DSPs.
- Content: 3-10 short clips anchored to the song; one story about inspiration or context; one clear save-or-add call-to-action.

Phase 4: Release Week (day 0 to day 7)
- Day 0: verify song is live everywhere; verify artist pages; pin or highlight the release; ask for saves, not just streams.
- Days 1-7: post 2-6 pieces; email or SMS list if you have one; submit to user playlists or curators; engage comments without doom-scrolling.

Phase 5: Post-Release Push (week 2 to week 8)
- Do: keep posting the same song with new angles; track cities or regions with traction; if a clip hits, make five quick variations.
- Avoid: panicking over week-one streams; jumping distributors impulsively; spamming every playlist service.

Phase 6: Catalog Maintenance (quarterly)
- Checklist: confirm all works registered (PRO, MLC, admin); audit credits or splits; check for unclaimed royalties; update playlist placements and performance notes.

Release readiness quick checklist
- Final master WAV is done.
- Cover art ready.
- Writers and splits agreed.
- Feature terms agreed if any.
- Metadata finalized (title, explicit, credits).
- Distributor upload scheduled.
- Editorial pitch submitted when applicable.
"""
        ),
        EducationTopic(
            id: "distributors",
            title: "Distributors",
            category: "Release",
            summary: "Pros, watch-outs, and best-fit notes for major indie distributors and label-service options.",
            body: """
Distributors and How to Pick One
Remember: a distributor is infrastructure, not strategy. Choose the one that matches your release frequency, protects ownership, and does not add friction.

What to prioritize
- Keep ownership: avoid giving up masters or publishing unless value is clear.
- Match speed: high-output artists need quick uploads; low-volume artists need stability and support.
- Reporting clarity: clean splits and transparent payouts reduce disputes.
- Extras matter only if you use them: sync, publishing admin, and marketing tools can sit idle if you do not have a plan.

Distributor cheat sheet

Too Lost
- What it is: modern, artist-first distributor focused on transparency.
- Strengths: clean UI, detailed reporting, flexible deals, strong indie adoption.
- Watch-outs: smaller than legacy players, fewer bundled extras.
- Best for: artists wanting clarity and control without corporate bloat.

CD Baby
- What it is: one-time-fee distributor oriented toward long-term catalog stability.
- Strengths: no annual fees, physical distribution options, optional publishing admin.
- Watch-outs: takes a percentage and can pay out slowly; not great for frequent releases.
- Best for: occasional releasers who want set-it-and-forget-it longevity.

DistroKid
- What it is: subscription-based, unlimited-release distributor.
- Strengths: fast uploads, low cost, widely accepted, strong split tools.
- Watch-outs: add-on fees and limited support; publishing handled elsewhere.
- Best for: high-output artists prioritizing speed and simplicity.

TuneCore
- What it is: full-service platform with distribution, publishing admin, and sync access.
- Strengths: robust analytics, global reach, education resources, scalable ecosystem.
- Watch-outs: higher cost and heavier interface.
- Best for: artists who want everything under one roof and do not mind paying more.

Amuse
- What it is: mobile-first distributor with free and paid tiers.
- Strengths: no upfront cost on free tier, clean UX, label services if you grow.
- Watch-outs: slower release times on free plan, fewer advanced tools.
- Best for: early-stage artists testing releases with minimal spend.

AWAL
- What it is: selective distributor offering label-style support without ownership grabs.
- Strengths: playlist pitching, marketing support, strong DSP credibility.
- Watch-outs: application required, revenue share, less DIY freedom.
- Best for: artists with traction who want partner support while keeping ownership.

Stem
- What it is: invite-only distributor built for collaboration-heavy music.
- Strengths: excellent split accounting, transparent payouts, artist-friendly terms.
- Watch-outs: hard to access, not beginner-focused.
- Best for: producers and artists working with many collaborators.

Ditto Music
- What it is: subscription-based distributor with international emphasis.
- Strengths: unlimited releases, chart registration in some regions, global reach.
- Watch-outs: mixed support reputation, dated interface.
- Best for: UK, EU, or globally focused indie artists.

Symphonic Distribution
- What it is: selective distributor with genre-specific expertise and marketing services.
- Strengths: strong in hip-hop, Latin, and EDM; YouTube monetization support.
- Watch-outs: revenue share and selective onboarding.
- Best for: artists whose genre aligns with Symphonic strengths.

Believe
- What it is: global distribution and label-services company.
- Strengths: worldwide reach, strong DSP relationships, scalable infrastructure.
- Watch-outs: corporate feel, less transparency, selective.
- Best for: artists moving from DIY to larger operations.

Empire
- What it is: artist-driven distributor known for breaking major indie acts.
- Strengths: marketing power, cultural relevance, deal flexibility.
- Watch-outs: highly selective and business-heavy relationships.
- Best for: artists building movements or strong cultural brands.

UnitedMasters
- What it is: distributor focused on brand partnerships and creator culture.
- Strengths: brand deal access, cultural positioning, clean platform.
- Watch-outs: revenue share on free tier, fewer traditional artist services.
- Best for: artists prioritizing brand and commercial opportunities.

ONErpm
- What it is: hybrid distributor offering DIY and label-style services.
- Strengths: global presence, strong Latin market reach, flexible deal tiers.
- Watch-outs: interface can feel busy and terms vary by deal.
- Best for: international artists or those targeting Latin or global markets.

RouteNote
- What it is: budget-friendly distributor with free and paid options.
- Strengths: no upfront cost on free tier, straightforward distribution.
- Watch-outs: revenue share on free plan and limited support.
- Best for: cost-conscious artists experimenting with releases.

LANDR Distribution
- What it is: distribution arm of LANDR mastering.
- Strengths: seamless workflow with mastering, simple setup.
- Watch-outs: less customizable, fewer advanced services.
- Best for: self-produced artists who want convenience over complexity.
"""
        )
    ]
}
