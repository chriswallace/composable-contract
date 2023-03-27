import { Ownable } from "@openzeppelin/contracts/access/Ownable";
import { ERC721 } from "@openzeppelin/contracts/token/ERC721/ERC721";

pub contract ComposableImage is ERC721, Ownable {
  pub struct ImageComponent {
    id: u256,
    uri: String,
  }

  pub struct ComposedImage {
    component_ids: Vec<u256>,
    background_id: u256,
  }

  pub image_components: Map<u256, ImageComponent>;
  pub composed_images: Map<u256, ComposedImage>;
  pub backgrounds: Map<u256, ImageComponent>;
  pub token_id_counter: u256;

  pub def __init__():
    self.ERC721("ComposableImage", "CIMG") => {}

  pub def create_image_component(uri: String) -> u256:
    require! self.is_owner(), "Not the owner.";
    self.token_id_counter = self.token_id_counter + 1;
    self.image_components[self.token_id_counter] = ImageComponent(self.token_id_counter, uri);
    self.token_id_counter

  pub def create_background(uri: String) -> u256:
    require! self.is_owner(), "Not the owner.";
    self.token_id_counter = self.token_id_counter + 1;
    self.backgrounds[self.token_id_counter] = ImageComponent(self.token_id_counter, uri);
    self.token_id_counter

  pub def compose_image(component_ids: Vec<u256>, background_id: u256) -> u256:
    require! self.backgrounds.contains_key(background_id), "Invalid background ID";
    self.token_id_counter = self.token_id_counter + 1;
    self.composed_images[self.token_id_counter] = ComposedImage(component_ids, background_id);
    self.safe_mint(msg.sender, self.token_id_counter);
    self.token_id_counter

  pub def update_background(token_id: u256, new_background_id: u256):
    require! self.is_approved_or_owner(msg.sender, token_id), "Not owner nor approved";
    require! self.backgrounds.contains_key(new_background_id), "Invalid background ID";
    self.composed_images[token_id].background_id = new_background_id;

  pub def token_uri(token_id: u256) -> String:
    require! self.exists(token_id), "ERC721Metadata: URI query for nonexistent token";
    let composed_image = self.composed_images[token_id];
    let json = "{\"name\":\"Composed Image\", \"description\":\"A composable image\", \"background_uri\":\"";
    json = json.append(self.backgrounds[composed_image.background_id].uri).append("\", \"components\":[");
    for i in 0..composed_image.component_ids.length():
      let component = self.image_components[composed_image.component_ids[i]];
      json = json.append("{\"component_id\":").append(component.id.to_string()).append(", \"uri\":\"").append(component.uri).append("\"}");
      if i < composed_image.component_ids.length() - 1:
        json = json.append(",");
    json = json.append("]}");
    "data:application/json;charset=utf-8,".append(json)
}
