# parallelReduce Guide
The purpose of this guide is to bring together all of the information we have about the parallelReduce and to provide additional clarity on how it works and why we use it.

## Description
There are layers of abstraction to the parallelReduce structure that we should understand first.  Generally speaking it is an abbreviation of a while loop pattern. The variables you set are repeatedly updated uniquely by each one of your participants until the loop condition no longer holds. Values are updated via return statements, continue is implicit.

If some thing or many things can be done by many different people, you use a parallelReduce to handle the fork and cases.

A fork is a race between API members where we are unsure who exactly is performing the next consensus operation, this is why they are common with API members – which offer functionality to many different participants. Fork ends in the execution of a switch structure, executing the appropriate case (if Bob1 wins do this, if Bob2 wins do that). Read more about fork intuition here, including the underlying code that makes up the fork keyword.

### [What is a race?](https://docs.reach.sh/rsh/step/#race)

Read [this guide](https://docs.reach.sh/guide/ctransfers/#guide-ctransfers) about when to use what kind of consensus transfer

After you understand that you can examine the structure of parallelReduce components and their definitions in the [docs](https://docs.reach.sh/rsh/consensus/#p_29)

Let's start by looking at the most simple parallelReduce that we could implement

```js
const B = API('Bobs', {
  countUp: Fun([], UInt),
});
init();
A.publish();
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
```

Here we declare one API member function `countUp` for the Bobs API on line 8, then define its functionality on lines 16-21
Line 13 declares one loop variable `count` and initializes it to 0, declaring the parallelReduce
Line 14 sets the invariant to true, this is useless except to simplify the demonstration
Line 15 is a standard while loop condition, run until the condition breaks
Line 16 is the definition of our api member function `countUp`
API.functionName
Takes zero arguments
Line 17 starts a return
0 is in the pay expression. This function takes no payment from the user. You can specify any number to be paid by the user here. You can also omit the 0 and Reach will synthesize this to zero.
ret is the return function to return the function signature value to the caller. Here we have said that the return value is a UInt on line 8. More information on this below
Line 18 adds 1 to the current count and stores that in newCount
Line 19 invokes that return function and returns the newCount
Line 20 updates the `count` loop variable to `newCount`

### .api_
All API member functions must rely only on consensus state and the function inputs.

The api member function has a consensus reduction specification function that takes an argument. Here that function is called `ret`.

```js
  .api_(Guest.register, () => {
    check(!done, "event started");
    check(isNone(Guests[this]), "already registered");
    return [ reservation, (ret) => {
      enforce(thisConsensusTime() < deadline, "too late");
      Guests[this] = true;
      ret(null);
      return [ false, howMany + 1];
    }];
  })
```

`ret` must be called inside the api member function to provide the return value to the api caller. Below on line 17 is the function signature for the API member function `register`. It takes no arguments and returns Null

```js
const Guest = API('Guest', {
  register: Fun([], Null),
});
```

And here again is the implementation of the `register` function, this time pointing to the inputs and outputs. Line 37 specifies Whose API and which function we are referencing (Guest.register) and then it takes no arguments. Line 43 invokes our `ret` function and returns a null value to the caller.

```js
  .api_(Guest.register, () => {
    check(!done, "event started");
    check(isNone(Guests[this]), "already registered");
    return [ reservation, (ret) => {
      enforce(thisConsensusTime() < deadline, "too late");
      Guests[this] = true;
      ret(null);
      return [false, howMany + 1];
    }];
  })
```

// here, image of what happens if we change ret to true