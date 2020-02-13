package com.easyconnect.easyconnectap.errorhandling;

import com.easyconnect.easyconnectap.util.HttpStatusCodes;

import org.reactivestreams.Publisher;

import io.reactivex.Flowable;
import io.reactivex.functions.Function;
import retrofit2.HttpException;

public class HttpErrorRetryChecker implements Function<Flowable<? extends Throwable>, Publisher<?>> {
    public static final int DEFAULT_RETRY_COUNT = 2;
    private final int maxRetries = 3;
    private int retryCount = 0;

    /**
     * * Public empty constructor for HttpErrorRetryChecker
     */
    public  HttpErrorRetryChecker() {

    }

    @Override
    public Publisher<?> apply(Flowable<? extends Throwable> flowable) throws Exception {
        return flowable.flatMap((Function<Throwable, Publisher<?>>) throwable -> {
            if (throwable instanceof HttpException) {
                HttpException httpException = (HttpException) throwable;
                if (httpException.code() == HttpStatusCodes.HTTP_UNAUTHORIZED && retryCount < maxRetries) {
                    retryCount++;
                    return Flowable.just(true);
                }
            }
            return Flowable.error(throwable);
        });
    }
}