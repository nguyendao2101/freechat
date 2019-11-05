package vn.team.freechat.data;

import com.tvd12.ezyfox.binding.annotation.EzyArrayBinding;
import com.tvd12.ezyfox.binding.annotation.EzyValue;

import dev.morphia.annotations.Entity;
import dev.morphia.annotations.Id;
import lombok.Getter;
import lombok.Setter;
import lombok.ToString;
import vn.team.freechat.common.data.ChatData;
import vn.team.freechat.constant.ChatEntities;
import vn.team.freechat.constant.ChatGroupType;

@Setter
@Getter
@ToString
@Entity(value = ChatEntities.CHAT_GROUP, noClassnameStored = true)
@EzyArrayBinding(indexes= {"id","name"})
public class ChatGroup extends ChatData {
	private static final long serialVersionUID = 7990470991570815848L;
	
	@Id
	@EzyValue("1")
	private long id;
	
	@EzyValue("6")
	private String name;
	
	@EzyValue("7")
	private int maxUser;
	
	@EzyValue("8")
	private String owner;
	
	@EzyValue("9")
	private ChatGroupType type;
}