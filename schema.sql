-- Home Storage Management Database Schema
-- PostgreSQL Database Schema for tracking storage across floors, rooms, racks, and boxes

-- Enable UUID extension for unique identifiers
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Floors table
CREATE TABLE floors (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL UNIQUE, -- 'basement', 'ground', 'upstairs'
    level INTEGER NOT NULL, -- 0 for basement, 1 for ground, 2 for upstairs
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Rooms table
CREATE TABLE rooms (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    floor_id UUID NOT NULL REFERENCES floors(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(floor_id, name) -- Ensure unique room names per floor
);

-- Storage Racks table (optional - not all rooms have racks)
CREATE TABLE racks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    room_id UUID NOT NULL REFERENCES rooms(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    position VARCHAR(50), -- e.g., "Wall A", "Corner", "Left side"
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(room_id, name) -- Ensure unique rack names per room
);

-- Boxes table (with NFC tags)
CREATE TABLE boxes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nfc_tag_id VARCHAR(255) NOT NULL UNIQUE, -- Unique NFC tag identifier
    name VARCHAR(100),
    description TEXT,
    -- Box can belong to either a rack OR directly to a room
    rack_id UUID REFERENCES racks(id) ON DELETE CASCADE,
    room_id UUID REFERENCES rooms(id) ON DELETE CASCADE,
    -- Ensure box belongs to either rack or room, but not both
    CONSTRAINT box_location_check CHECK (
        (rack_id IS NOT NULL AND room_id IS NULL) OR
        (rack_id IS NULL AND room_id IS NOT NULL)
    ),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Items table (items stored in boxes)
CREATE TABLE items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    box_id UUID NOT NULL REFERENCES boxes(id) ON DELETE CASCADE,
    name VARCHAR(200) NOT NULL,
    description TEXT,
    quantity INTEGER NOT NULL DEFAULT 1 CHECK (quantity >= 0),
    tag VARCHAR(100), -- Category/label tag for the item
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Item Groups table (for grouping related items)
CREATE TABLE item_groups (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(200) NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Item Group Members (many-to-many: items can belong to multiple groups)
CREATE TABLE item_group_members (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    item_id UUID NOT NULL REFERENCES items(id) ON DELETE CASCADE,
    group_id UUID NOT NULL REFERENCES item_groups(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(item_id, group_id) -- Prevent duplicate group memberships
);

-- Item Links table (for linking items to other items with relationship types)
CREATE TABLE item_links (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    item_id_1 UUID NOT NULL REFERENCES items(id) ON DELETE CASCADE,
    item_id_2 UUID NOT NULL REFERENCES items(id) ON DELETE CASCADE,
    relationship_type VARCHAR(100), -- e.g., 'related', 'part_of', 'replacement', 'compatible'
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    -- Ensure item_id_1 != item_id_2
    CONSTRAINT item_links_different_items CHECK (item_id_1 != item_id_2)
);

-- Create indexes for better query performance
CREATE INDEX idx_rooms_floor_id ON rooms(floor_id);
CREATE INDEX idx_racks_room_id ON racks(room_id);
CREATE INDEX idx_boxes_rack_id ON boxes(rack_id);
CREATE INDEX idx_boxes_room_id ON boxes(room_id);
CREATE INDEX idx_boxes_nfc_tag_id ON boxes(nfc_tag_id);
CREATE INDEX idx_items_box_id ON items(box_id);
CREATE INDEX idx_items_tag ON items(tag);
CREATE INDEX idx_item_group_members_item_id ON item_group_members(item_id);
CREATE INDEX idx_item_group_members_group_id ON item_group_members(group_id);
CREATE INDEX idx_item_links_item_id_1 ON item_links(item_id_1);
CREATE INDEX idx_item_links_item_id_2 ON item_links(item_id_2);
-- Unique index to prevent duplicate bidirectional links
-- Using a function to normalize the pair order
CREATE UNIQUE INDEX idx_item_links_unique_pair ON item_links(
    CASE WHEN item_id_1 < item_id_2 THEN item_id_1 ELSE item_id_2 END,
    CASE WHEN item_id_1 < item_id_2 THEN item_id_2 ELSE item_id_1 END
);

-- Create a function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers to auto-update updated_at
CREATE TRIGGER update_floors_updated_at BEFORE UPDATE ON floors
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_rooms_updated_at BEFORE UPDATE ON rooms
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_racks_updated_at BEFORE UPDATE ON racks
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_boxes_updated_at BEFORE UPDATE ON boxes
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_items_updated_at BEFORE UPDATE ON items
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_item_groups_updated_at BEFORE UPDATE ON item_groups
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Optional: View to get full location path for boxes
CREATE OR REPLACE VIEW box_locations AS
SELECT 
    b.id AS box_id,
    b.nfc_tag_id,
    b.name AS box_name,
    b.description AS box_description,
    f.name AS floor_name,
    f.level AS floor_level,
    r.name AS room_name,
    CASE 
        WHEN b.rack_id IS NOT NULL THEN rack.name
        ELSE NULL
    END AS rack_name,
    CASE 
        WHEN b.rack_id IS NOT NULL THEN 'rack'
        ELSE 'room'
    END AS location_type
FROM boxes b
LEFT JOIN racks rack ON b.rack_id = rack.id
LEFT JOIN rooms r ON COALESCE(rack.room_id, b.room_id) = r.id
LEFT JOIN floors f ON r.floor_id = f.id;

-- View to get items with their full location path
CREATE OR REPLACE VIEW item_locations AS
SELECT 
    i.id AS item_id,
    i.name AS item_name,
    i.description AS item_description,
    i.quantity,
    i.tag AS item_tag,
    b.id AS box_id,
    b.nfc_tag_id,
    b.name AS box_name,
    f.name AS floor_name,
    f.level AS floor_level,
    r.name AS room_name,
    CASE 
        WHEN b.rack_id IS NOT NULL THEN rack.name
        ELSE NULL
    END AS rack_name,
    CASE 
        WHEN b.rack_id IS NOT NULL THEN 'rack'
        ELSE 'room'
    END AS location_type
FROM items i
JOIN boxes b ON i.box_id = b.id
LEFT JOIN racks rack ON b.rack_id = rack.id
LEFT JOIN rooms r ON COALESCE(rack.room_id, b.room_id) = r.id
LEFT JOIN floors f ON r.floor_id = f.id;

-- View to get item groups with their member count
CREATE OR REPLACE VIEW item_groups_summary AS
SELECT 
    ig.id AS group_id,
    ig.name AS group_name,
    ig.description AS group_description,
    COUNT(igm.item_id) AS member_count,
    ig.created_at,
    ig.updated_at
FROM item_groups ig
LEFT JOIN item_group_members igm ON ig.id = igm.group_id
GROUP BY ig.id, ig.name, ig.description, ig.created_at, ig.updated_at;

-- Insert initial floor data
INSERT INTO floors (name, level) VALUES
    ('basement', 0),
    ('ground', 1),
    ('upstairs', 2);

