'reach 0.1';

export const main = Reach.App(() => {
  const A = Participant('Alice', {
    // Specify Alice's interact interface here
  });
  const B = API('Bobs', {
    countUp: Fun([], UInt),
  });
  init();
  A.publish();
  // must occur in consensus step
  const [count] = parallelReduce([0])
    .invariant(true)
    .while(count < 4)
    .api_(B.countUp, () => {
      return[0, (ret) => {
        const newCount = count + 1;
        ret(newCount);
        return[newCount];
      }];
    })
  commit();
  exit();
});
