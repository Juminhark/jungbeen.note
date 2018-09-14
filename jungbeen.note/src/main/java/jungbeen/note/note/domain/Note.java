package jungbeen.note.note.domain;

public class Note {
	private int id;
	private String name;
	private String color;
	private int shareCnt;
	
	public Note() {
		this.shareCnt = -1;
	}
	
	public int getId() {
		return id;
	}
	public void setId(int id) {
		this.id = id;
	}
	public String getName() {
		return name;
	}
	public void setName(String name) {
		this.name = name;
	}
	public String getColor() {
		return color;
	}
	public void setColor(String color) {
		this.color = color;
	}
	public int getShareCnt() {
		return shareCnt;
	}
	public void setShareCnt(int shareCnt) {
		this.shareCnt = shareCnt;
	}
}
