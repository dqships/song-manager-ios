import Foundation

enum EducationTopicsCollaboration {
    static let topics: [EducationTopic] = [
        EducationTopic(
            id: "collaborators",
            title: "Collaborators",
            category: "Collaboration",
            summary: "Roles to capture for writing, performance, production, engineering, business, and marketing.",
            body: """
Collaborator Roles

Songwriting and Composition
These collaborators contribute to the musical and lyrical DNA of the song.
- Lyricist: writes the lyrics only.
- Composer: writes the melody and or harmony.
- Songwriter: writes both lyrics and melody.
- Topliner: writes vocal melodies and lyrics over an existing instrumental.
- Co-writer: shares songwriting credit in any combination.
- Arranger: structures the song (sections, chord voicings, transitions).

Performance and Vocals
These collaborators contribute recorded performances.
- Lead Vocalist: primary vocal performer.
- Featured Artist (feat.): guest performer credited publicly.
- Background Vocalist: harmonies, ad-libs, backing vocals.
- Session Vocalist: paid vocalist, often uncredited publicly.
- Instrumentalist: guitar, bass, keys, drums, strings, and more.
- Session Musician: hired performer for specific parts.

Production and Creation
These collaborators shape the sound and sonic identity.
- Producer: oversees creative direction and sound.
- Co-Producer: shares production responsibilities.
- Beatmaker: creates the instrumental or beat.
- Music Programmer: programs MIDI, drums, synths.
- Sound Designer: creates custom sounds, textures, effects.
- Additional Producer: contributes specific production elements.

Engineering and Audio
These collaborators handle technical execution and polish.
- Recording Engineer: captures vocals and instruments.
- Mixing Engineer: balances and processes the track.
- Mastering Engineer: final loudness, clarity, and consistency.
- Vocal Engineer: specializes in vocal recording and processing.
- Assistant Engineer: supports sessions and technical setup.

Creative Direction and Visuals
These collaborators influence how the song is presented.
- Creative Director: overall artistic vision.
- Cover Art Designer: single or album artwork.
- Photographer: press and promotional photos.
- Videographer: music videos and visuals.
- Video Director: oversees music video production.

Business, Rights, and Administration
These collaborators protect, distribute, and monetize the song.
- Publisher: manages songwriting rights and royalties.
- Publishing Administrator: registers and collects publishing royalties.
- Label: funds, markets, and distributes the release.
- Distributor: delivers the song to DSPs.
- Manager: oversees career and strategy.
- A and R: creative development and song placement.
- Music Supervisor: places songs in film, TV, and games.

Marketing and Promotion
These collaborators drive audience discovery.
- Marketing Strategist: release and growth planning.
- PR or Publicist: media outreach and press.
- Playlist Curator: editorial or independent playlists.
- Radio Promoter: radio placement and spins.
- Social Media Strategist: content and platform growth.
- Influencer or UGC Creator: viral or promo content.

Legal and Clearance
These collaborators handle risk and compliance.
- Entertainment Lawyer: contracts and disputes.
- Rights Clearance Specialist: samples, interpolations, licenses.
- Royalty Accountant: royalty tracking and audits.
"""
        ),
        EducationTopic(
            id: "splits-and-credits",
            title: "Splits and Credits",
            category: "Collaboration",
            summary: "How to track publishing and master splits, credits, and agreements cleanly.",
            body: """
Splits and Credits (How to Track It Cleanly)
Splits are the backend truth. Credits are the public story. Both matter.

Two Types of Splits

Publishing splits (song)
Who wrote the lyrics, melody, and composition.
These splits affect PRO performance royalties, mechanical royalties, and the publishing side of sync.

Master splits (recording)
Who owns the recording and shares in master revenue.
These splits affect streaming master royalties, downloads, and the master side of sync.

Common Split Structures
- Equal splits: simple and fast, common in co-writes. Can be unfair if contributions are very unequal.
- Weighted splits: more accurate but requires honest conversation.
- Buyouts or work-for-hire: someone gets paid upfront instead of royalties. Requires clear paperwork to avoid disputes.

Credits Versus Contributions
Credits (public facing): primary artist, featured artist, producer, songwriter.
Contributions (backend detail): topline, beat or instrumental, arrangement, recording engineering, background vocals, instrument performance.

Split Sheet Essentials (Minimum Fields)
- Song title and date.
- Legal names (not stage names).
- PRO affiliations (ASCAP, BMI, etc).
- IPI or CAE numbers if available.
- Publishing split percent per writer.
- Contact info.
- Signatures (even digital).

Producer Deals (Common Patterns)
1) Flat fee only: clean and simple, no ongoing claims if documented properly.
2) Fee plus points: producer gets a percent of master income.
3) Fee plus publishing: producer gets a share of songwriting.
Rule: clarify which of the above applies - do not assume.

Conflict Prevention Rules
- Decide splits before release.
- Write it down even with friends.
- Store the final agreement in one place.
- Do not change splits later without written confirmation.
"""
        ),
        EducationTopic(
            id: "common-mistakes",
            title: "Common Mistakes",
            category: "Collaboration",
            summary: "Quiet failures that cost money, ownership, or time and how to avoid them.",
            body: """
Common Indie Music Mistakes (and How to Avoid Them)
Quiet failures that cost money, time, or ownership. Use the fixes as a pre-release checklist.

Money mistakes
- Assuming your distributor collects publishing
  - Reality: most distributors collect master royalties only.
  - Fix: register works with a PRO, the MLC, and optionally a publishing admin.
- Skipping MLC registration
  - Reality: US digital mechanicals go unclaimed without it.
  - Fix: register songs with accurate writer and publisher info.
- Ignoring SoundExchange
  - Reality: digital radio royalties (Pandora, SiriusXM) are separate.
  - Fix: register once and keep featured artist info correct.
- Forgetting neighboring rights
  - Reality: some royalties are collected country by country.
  - Fix: use a neighboring rights solution or register where it matters most.

Credit and split mistakes
- No split sheet because you are friends
  - Reality: memory changes and relationships change.
  - Fix: agree in writing before release.
- Treating producers as work-for-hire without paperwork
  - Reality: producers often expect points or publishing.
  - Fix: write terms clearly: fee versus points versus publishing.
- Leaving session players uncredited
  - Reality: you forget who played what; disputes happen later.
  - Fix: track performer credits even if not public.

Metadata mistakes
- Inconsistent artist or title formatting
  - Reality: splits catalogs and confuses DSP profiles.
  - Fix: standardize spelling, punctuation, and featured artist formatting.
- Choosing featured versus collaborator tags poorly
  - Reality: feat. changes discovery and how credits display.
  - Fix: decide the credit strategy intentionally.
- Not saving ISRC or UPC
  - Reality: audits and distributor migrations get messy.
  - Fix: store ISRC per track and UPC per release.

Strategy mistakes
- Switching distributors to fix growth
  - Reality: distribution is infrastructure, not demand.
  - Fix: improve positioning, content loops, and release consistency.
- Releasing once, then disappearing
  - Reality: momentum decays fast.
  - Fix: set a release cadence and plan post-release content.
- Watching vanity metrics instead of behavior
  - Reality: likes do not pay.
  - Fix: track saves, repeats, playlist retention, and direct fan signups.

Legal or ownership mistakes (high impact)
- Using samples or interpolations without clearance
  - Reality: takedowns and lost revenue.
  - Fix: clear it or do not release commercially.
- Signing label services deals without understanding terms
  - Reality: deals can quietly control masters or term lengths.
  - Fix: know ownership, term, recoupment, and exit clauses before signing.

"""
        ),
        EducationTopic(
            id: "decision-trees",
            title: "Decision Trees",
            category: "Collaboration",
            summary: "Fast answers for distributor choice, publishing admin, SoundExchange, playlists, ads, and feat. decisions.",
            body: """
Decision Trees (Fast Answers for Common Artist Questions)
Quick decision trees to choose the right next step without overthinking.

Which distributor should I choose?
- How often do you release?
  - Every month or many singles: choose subscription or unlimited style.
  - A few times per year: one-time fee style can be fine.
- Do you want help beyond delivery?
  - No, I want control: DIY distributor.
  - Yes, I want pitching or marketing support: selective or label services distributor.
- Are you already showing traction?
  - Not yet: DIY distributor first.
  - Yes, clear demand: consider selective options.
Rule: switching distributors rarely fixes growth. Choose for workflow and costs, not hype.

Do I need a publishing administrator?
- Releasing songs with multiple writers: yes, strongly consider.
- Planning international growth: yes.
- Doing sync or Content ID seriously: yes.
- Releasing rarely and staying small: optional but still useful.
Shortcut: if you cannot confidently track registrations worldwide, a publishing admin helps.

Do I need SoundExchange?
- Are you getting played on non-interactive digital radio (Pandora radio, SiriusXM, iHeart digital radio)?
  - Yes or maybe: register.
  - Even if unsure: register anyway.
Why: it is separate from Spotify or Apple Music.

Should I focus on playlists or content?
- Do you already have content formats that perform?
  - Yes: double down on content loops.
  - No: start with simple content formats tied to one song.
- Are you getting saves or repeats but low discovery?
  - Yes: playlists can help discovery.
  - No: fix the music positioning or audience targeting first.

Should I run ads?
Only run ads if:
- Your song already gets saves organically.
- You have a clear audience target.
- You can measure cost per save and follower quality.
If your song is underperforming organically: do not ad your way out. Fix the positioning and content first.

Is this a feat. or a collab?
- Use feat. when one artist is primary and the other is a guest.
- Use joint artist or collaboration when both artists are equal partners, will promote equally, and you want both audiences to see it as a shared release.
"""
        )
    ]
}
