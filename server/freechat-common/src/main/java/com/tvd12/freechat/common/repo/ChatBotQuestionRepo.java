package com.tvd12.freechat.common.repo;

public interface ChatBotQuestionRepo {

    String findQuestionByIndex(int index);

    long count();
}
