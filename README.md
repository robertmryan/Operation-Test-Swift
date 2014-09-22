### Swift Operation Test

There seems to be much confusion about concurrent/asynchronous `NSOperation`. Now that
iOS 8 (and Mac OS 10.10) exposes the `finished` and `executing` properties, there is a common
reaction that the standard KVO keys would be, logically, `finished` and `executing`. That
is the standard pattern in writing KVO-compliant properties.

But `NSOperation` alway has (and as of this point in time, continues to) require KVO of
`isFinished` and `isExecuting`. See the _Configuring Operations for Concurrent Execution_ section of the 
[Operation Queue](https://developer.apple.com/library/mac/documentation/General/Conceptual/ConcurrencyProgrammingGuide/OperationObjects/OperationObjects.html#//apple_ref/doc/uid/TP40008091-CH101-SW1) 
section of the _Concurrency Programming Guide._

Note: This requirement, to post `isFinished` and `isExecuting` KVO, is only applicable if
writing asynchronous/concurrent operations, namely:

- Set `asynchronous` (and if supporting iOS 7.1 and earlier, `concurrent`) to `true`.

- When the operation starts, it completes asynchronously (i.e. after it returns from
the `start`/`main` function.

If you write a non-concurrent operation (or if it's a concurrent operation that happens to 
finish before `start`/`main` finishes), the problems arising from the failure to do the
appropriate KVO will not manifest themselves. But if it's truly a asynchronous/concurrent
operation, you will experience the following problems:

1. Dependencies between operations will never fire (because it awaits `isFinished` of the 
first operation before starting the second operation that depends upon it);

2. Use of `maxConcurrentOperationCount` in the `NSOperationQueue` will fail to be informed
of operations that finish, thus using up worker threads, and once you hit the maximum concurrent
operation count, the entire queue will deadlock.

---

By way of demonstration, see the `OperationTestSwiftTests` unit test. In this, I test 
both `GoodAsynchronousOperation` (which does the `isFinished`/`isExecuting` notifications) and
`BadAsynchronousOperation` (which doesn't). You'll see that with the appropriate notifications
the operations complete successfully, but if you don't, the dependent operation will never fire
(resulting in the expectation to never being fulfilled and the test will fail).

---

Rob Ryan <br />
22 September 2014