# Local shop — v1.2.0

Open from any top resource chip in the lobby, or Inventory→Shop. Five tabs: Featured, Supplies, Bundles, Exchange, Cosmetics. Existing five bottom routes remain; no combat shop button. All purchases use earned gold or existing robot shards. No real-money SDK, ads, fake ads or new premium currency.

## Catalog (normal profile)

| Offer | Price | Exact contents | Limit |
|---|---|---|---|
| Daily gift | Free |20 gold,5 materials,1 sweep ticket|1/UTC day|
| Starter |120 gold|200 gold,3 summon tickets,30 materials,1 Rare+0 equipment of your choice from12 templates|1/profile|
| Summon ticket |200 gold|1 ticket|Repeatable|
| Sweep tickets |150 gold|5 tickets|Repeatable|
| Repair kits |90 gold|3 kits|Repeatable|
| Materials |60 gold|10 materials|Repeatable|
| Hero cores |120 gold|3 cores|Repeatable|
| Hero growth |300 gold|100 gold,8 cores,20 materials|1/profile|
| Explorer |250 gold|8 sweep tickets,3 kits,20 materials|1/UTC day|
| Glacier/Bastion/Inferno bundle (3 offers)|600 gold|All4 Rare+0 slots of named set|Each1/profile|
| Glacier/Bastion/Inferno exchange (3 offers)|20 shards|Choose1 of4 Rare+0 slots in named set|Each3/UTC day|
| Magnet |40 shards|Permanent pet|Only if unowned|
| Medic/Bulwark |90 shards each|Permanent pet|Only if unowned|
| Frostling/Bomber |140 shards each|Permanent pet|Only if unowned|
| Jade/Ice/Amethyst finishes (3 offers)|50 shards each|Robot+weapon energy tint, aura, footsteps, tracer color, legacy bullet skin|Only if unowned|

23 catalog entries. Starter/hero bundle gold rebates are intentional one-time benefits, not an unlimited currency loop. Shards share the existing hero-exchange wallet, displayed explicitly before confirmation. Gear is fixed Rare+0; nothing random, automatically fused, dismantled or equipped. Existing first-clear pet unlocks still work. Cosmetics give no combat stats; bought items do not auto-equip.

## Cosmetics
Finish is a lightweight tint/effect set, not new painted hero/gun models. It uses existing sprites. Selected finish changes robot+held weapon tint, aura and friendly tracer palette; native elemental shapes/cores remain. Existing bullet skin1/2/3 is also granted for Jade/Ice/Amethyst. Equip explicitly from shop; Original removes finish. Applied at next run. Footsteps cap12 and expire0.5s, pause with the game; reduced effects removes aura/footsteps. No enemy projectile recoloring.

## Transaction rules and storage
Detail page previews all exact rewards, choice, price and limit. Confirmation creates a one-use quote bound to UI revision, profile and UTC day. Recheck funds, ownership, limits and whole inventory capacity (500) before deducting anything. Save purchase rewards/cost/count/receipt together using current temp+rename save. On failure restore in-memory currencies, inventory, cosmetics and counters. Repeated callbacks cannot pay/grant twice. One-time counts retained; old daily counts pruned on purchase. Last20 receipts persist. UTC is local device UTC, no backend anti-clock-tampering guarantee.

Shop uses additive `shop` section; no profile reset or inventory migration grant. Normal/admin separate. Admin price zero and limits bypassed for testing; owned pets/themes cannot duplicate and inventory capacity remains500. UI does not expose payments.

## Validation
All23 current suites pass with Godot4.6.3, import clean. New shop and shop_rollback plus21 existing suites. Regression includes checkpoints/x2/summon/profiles/combat. Shop UI EN audit zero VN leftovers across all23 detail/confirmation routes and tabs/receipt/history. Rendered360×800 via Xvfb/Mesa. No S23 Ultra FPS, APK or long-term economy-speed claim. Screens under previews/v1.2-shop-*.png.
