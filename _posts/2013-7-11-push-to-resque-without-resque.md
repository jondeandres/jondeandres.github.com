---
layout: post
title: Push jobs to Resque without Resque
---
At [Wuaki.tv](http://wuaki.tv) we are moving to a services oriented architecture and the first service we developed was the users service. We had to move all the users related logic to a new service and make our applications to use a service oriented model instead of the ActiveRecord model we had.

Actually we are using [Errbit](https://github.com/errbit/errbit) to collect the errors/crashes from our applications so we have the [Airbrake](https://github.com/airbrake/airbrake) gem as dependency in all the projects we need to monitor the errors. The Airbrake configuration we usually set, normally in a initializer, is something like this:

{% highlight ruby %}
{% include ruby/airbrake_config.rb %}
{% endhighlight %}

In the code above we see three dependencies, Airbrake, OurAmaizingQueue and AirbrakeDeliveryWorker. As you may know, [Resque](https://github.com/defunkt/resque) jobs need to be a module or class with a class method called `perform`. So even the Resque workers are executed by another application, we have a dependency with the job class constant. Of course, we have a dependency with OurAmaizingQueue that is just a wrapper to enqueue into Resque.

We wanted to avoid Resque and OurAmaizingQueue (that lives in a common internal gem) dependencies in our super-tiny-micro-awesome users service. So...what if we can push the job into the correct Resque queue without the Resque gem and our internal huge gem? We tried it and this is the result:

{% highlight ruby %}
{% include ruby/enqueue_to_resque.rb %}
{% endhighlight %}

The 'magic' is easy, we only need to encode a Hash into JSON with a `class` key that stores the class name of the job to be enqueued and a `args` key with the arguments for the job stored like an Array. This JSON is pushed into the tail of the list identified by the key `resque:queue:name_of_the_queue_to_use`.

Another important thing we shouldn't forget is to add the queue name to use into the `resque:queues` set to make Resque listening this queue.

The Airbrake initializer changes a bit cause we don't have the job class constant and we need to enqueue the job using a string.

{% highlight ruby %}
{% include ruby/airbrake_config_without_resque.rb %}
{% endhighlight %}

Cause we don't have the job class, we need to use explicity the queue name and the job class name. All these stuff was working fine while we only needed to enqueue jobs but finally our users service needs to perform its own Resque jobs, so we added Resque gem as dependency :-) and `MicroAwesomeService::Queue` became just a wrapper to enqueue jobs.
