# TAG Assignment: Individual Contribution and Reflection

**Name:** Muhammad Benyamin Vaseem
**Team:** TagTeam4 ([repository](https://github.com/benain-web/TagTeam4))
**Module:** DATA2007, Week 9

---

## 1. My contribution

### Roles
- **Repository owner.** Created the repo, set up branch protection rules and agreed the branching approach (feature branch, pull request, review, merge).
- **Work planning.** Led the split of the requirements into work packages and assigned them to team members.
- **Person 1: Overview page** (REQ-19, REQ-20, REQ-21).
- **Shared UI template** for the R Shiny dashboard so everyone's pages looked and behaved consistently.
- **Video.** Wrote the script and recorded the final presentation video.
- **Picking up dropped work.** When team members left late in the project, I took on part of their work (data tables, app fixes and documentation).

### Evidence on GitHub

| Date | What | Link |
|---|---|---|
| 14 Oct | Created the repository and initial README | [`59cb34d`](https://github.com/benain-web/TagTeam4/commit/59cb34d), [PR #1](https://github.com/benain-web/TagTeam4/pull/1) |
| 28 Oct | Overview page: user leaderboard, daily step goal and weekly active minutes (REQ-19/20/21) | [`973aea9`](https://github.com/benain-web/TagTeam4/commit/973aea9) |
| 28 Oct | Simplified the Overview code (removed 125 lines of repetition) | [`d7be894`](https://github.com/benain-web/TagTeam4/commit/d7be894) |
| 28 Oct | Reusable UI template (`viz_card`, `data_table`, `section_page`, `mod_template`) | [`d98def5`](https://github.com/benain-web/TagTeam4/commit/d98def5), [PR #2](https://github.com/benain-web/TagTeam4/pull/2) |
| 2 Nov | Reviewed and merged the skeleton app into `dev` | [PR #4](https://github.com/benain-web/TagTeam4/pull/4) |
| 4 Nov | Fixed app loading (helper sourcing, sleep data path, sleep filter bug), removed duplicate files and added filterable data tables (REQ-16/17/18) | [`cf909f3`](https://github.com/benain-web/TagTeam4/commit/cf909f3), [PR #7](https://github.com/benain-web/TagTeam4/pull/7) |
| 4 Nov | Rewrote the README with project overview, setup steps and structure | [`cb61680`](https://github.com/benain-web/TagTeam4/commit/cb61680) |

I authored 12 of the 33 commits in the repository (including merges), with the rest spread across four teammates.

Work not visible in the commit history: checking the Fitbit data before building (33 users rather than the stated 30, duplicate sleep rows, zero-step non-wear days), running the requirement brainstorm and task split, and writing and recording the video.

---

## 2. Reflection on teamwork

### How we worked
We met weekly on Microsoft Teams and used meeting transcriptions to share outcomes with anyone who couldn't attend. We brainstormed the requirements as a group, grouped related ones into work packages and gave each person a data area. Code went through feature branches and pull requests into `dev`.

### Linking to Tuckman's model
- **Forming.** Early on we were clear on roles and set up the repo, login and app skeleton quickly. Communication was good at this stage.
- **Storming.** Some people were unsure how to use the agreed git structure, and this was never fully resolved. Two to three members stopped contributing, and because we only met weekly we didn't notice until late.
- **Norming.** The remaining members adapted. I and others volunteered to take on the dropped requirements, and teammates who knew R Shiny helped those of us who were new to it.
- **Performing.** In the final days we integrated the Sleep, Heart Rate, Intensity and Overview pages, fixed the app so it loaded end to end, and delivered a working dashboard.

We did not move through the stages in a straight line. Losing members late pushed us back into storming just when we should have been performing, which is a known weakness of the model's linear view.

In **Belbin** terms, I mostly acted as **Coordinator** (splitting work, assigning roles) and **Implementer** (templates, fixes, integration). Sam acted as a strong **Specialist** on the app skeleton and integration.

### Retrospective

| Went well | Didn't go well | What we'll change |
|---|---|---|
| Adapted quickly to major changes in team structure and picked up dropped work | Late, last-minute merges on the final day | Set personal submission deadlines for each piece of work, well before the hand-in |
| Clear roles and good communication at the start and end | The git workflow was agreed but not explained clearly enough, so it caused confusion | Write a short contributing guide with the exact branch and PR steps |
| Meeting transcripts kept absent members informed | Weekly meetings meant we found out about dropouts too late | Short mid-week check-ins so blockers are raised quickly |
| Good R Shiny skill growth through peer support | Some requirements (REQ-07, 12, 22, 24, 25) were not delivered because the owners left or submitted too late | Start earlier and agree a clear end goal and a minimum viable dashboard |
| Shared UI template kept pages consistent | One person presented everyone's work | Have each member present their own section |

### What I learned
- **R Shiny:** how the UI and server sides fit together, and how to build reusable modules.
- **Git in a team:** branch protection, pull requests and resolving integration problems.
- **Adapting under pressure:** reprioritising when the team changed and still meeting the deadline.
- **Submitting early:** late work is hard to integrate and leaves no time for review.

### Next steps for the January project
I will push for a written plan that gives each person deliverables and internal deadlines, a contributing guide for the repo, and a quick mid-week check-in. I also want an earlier start, a clearly defined end goal and a presentation shared across the whole team.

---

## 3. Peer video reviews

**Group 10.** The team clearly showed the steps they took for each part of the task and explained how they used the Crazy 8s ideation technique and other methods to work effectively together. They used a good variety of visuals and explained how a user could act on the data to change their behaviour. The team reflection was a strength: they highlighted what worked, what needed improving and how they would deal with those issues next time.

**Group 3.** The dashboard had a very clear, simple interface that was intuitive and easy to use. Using statistics such as correlation gave a different perspective on the data, beyond the usual summaries. The video could have gone further on how they reached their design choices and how the team worked together.

**JAYLS.** The team set up clear ways of working early and used agenda cards to track tasks, so they came across as very well organised. They did a good amount of data exploration from the start and used PowerPoint well to show what they found and how they dealt with the data issues. The dashboard had useful filters and nice interactive visuals.

**Group 7.** Using k-means clustering to understand the data at the start was a good idea that set them apart. Presenting findings as "awards" was a fun and memorable way to highlight the data. They explained well how R Shiny's UI and server sides work, and a custom colour template gave the dashboard a clean look.

**Group 9.** The overview page was strong, with interesting derived measures such as BMI, clear colour coding for different levels, good aggregation and effective heatmaps in a simple design. They tracked whether data was entered manually and added useful context, such as a bank holiday possibly explaining poorer sleep across users. They were open about the gaps in some metrics and the challenges of handling large datasets, and explained how they would deal with those challenges. Their idea of using stakeholder feedback to refine the dashboard and plan future improvements was a good touch.

**Group 8.** The team gave a good account of their initial exploration of the dataset, the data quality problems they found and how they dealt with them. They explained their solution's architecture well, showing how the different parts fit together.

**Group 2.** The team split the work into sections and used reusable functions to save time and keep everyone's work consistent. Their analysis stood out for being different from other groups: a calorie-burn analysis, a leaderboard, heart rate split by time of day, and lots of comparison between individual users and the cohort average. They demonstrated how quickly the app reacts to changes in real time and used clear keys so viewers could interpret the charts.
