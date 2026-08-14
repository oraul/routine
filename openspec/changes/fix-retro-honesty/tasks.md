## 1. A failure is a failure and nothing else

- [ ] 1.1 Red→green: expected non-zero exits (`tdd.red`,
      `ticket.next` 3 and 4) leave the failure counts alone, a
      passing red is named as the anomaly, and script failures count
      only path-shaped script fields

## 2. A refusal is not a transition

- [ ] 2.1 Red→green: block pairing ignores refused `ticket.block` and
      `ticket.unblock` records, so no phantom block survives

## 3. The queue ranks by pain, not by luck

- [ ] 3.1 Red→green: the deepening queue orders by failure count with
      rate and runs shown, so one unlucky run cannot head it
