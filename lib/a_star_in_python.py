import random
import time

class Node:
    def __init__(self,
                identifier, 
                x, 
                y, 
                latitude = None, 
                longitude = None):
        '''
        initializes a node object with identifier, coordinates, and optional GPS data
        '''
        
        # unique label/identifier for the node
        self.identifier = identifier
        # x - coord
        self.x = x 
        # y - coord
        self.y = y
        # latitude to be used later
        self.latitude = latitude
        # longitude to be used later
        self.longitude = longitude
        # neighbors and their edge weights
        self.neighbors = {} 

        '''heuristics initially set to infinity until true costs are known'''
        # cost from start to current node
        self.g_cost = float('inf')
        # estimate of cost from current node to goal node
        self.h_cost = float('inf')
        # total cost (g and h), used to prioritize nodes
        self.f_cost = float('inf')
        # used for path reconstruction
        self.parent = None 

        '''
        weight = 1 for simple testing purposes. 
        later we will incorporate GPS coordinates using some heuristic measure such as euclidean distance for edge weights
        '''
    def add_neighbor(self, neighbor_node, weight = 1):
            self.neighbors[neighbor_node] = weight

def heuristic (node, goal):
    # using manhattan distance for testing purposes (due to only having 4-way direction currently)
    return abs(node.x - goal.x) + abs(node.y - goal.y)

def a_star_search(start, goal):
    # contains nodes that have been discovered but not evaluated
    open_set = set([start])
    # contains nodes that have been evaluated
    closed_set = set()

    start.g_cost = 0
    start.h_cost = heuristic(start, goal)
    start.f_cost = start.h_cost

    while open_set:
        # computes the f_cost value and uses for comparison to find the min (lowest cost node)
        current = min(open_set, key = lambda node: node.f_cost)
        # if current reaches goal, return how we got there
        if current == goal:
            return reconstruct_path(current, start, goal)

        # passing our now evaluated node to closed_set
        open_set.remove(current)
        closed_set.add(current)

        for neighbor in current.neighbors:
            # if we've already evaluated the neighbor, keep going
            if neighbor in closed_set:
                continue
            tentative_g_score = current.g_cost + current.neighbors[neighbor]

            # if we reach a neighbor thats not in open_set, add it to be evaluated later
            if neighbor not in open_set:
                open_set.add(neighbor)
            # else if our tenative gscore costs more/equal to the neighbors cost, keep going
            elif tentative_g_score >= neighbor.g_cost:
                continue
            # update our neighbor node cost values
            neighbor.parent = current
            neighbor.g_cost = tentative_g_score
            neighbor.h_cost = heuristic(neighbor, goal)
            neighbor.f_cost = neighbor.g_cost + neighbor.h_cost
    # return None if no path found
    return None

def reconstruct_path(current, start, goal):
    # record of where we went
    path = [goal]
    while current is not None and current != start:
        path.append(current)
        current = current.parent
    # making sure path includes start
    path.append(start)
    # return the reverse of our path
    return path[::-1]


def create_grid(grid_size, obstacle_probability):

    # specify the default value for a missing key is an empty dictionary
    grid_dict = {}

    # making sure start and goal are not obstacles
    start_node = Node(identifier = (0, 0), x = 0, y = 0)
    goal_node = Node(identifier = (grid_size - 1, grid_size -1), x = grid_size - 1, y = grid_size - 1)
    grid_dict[start_node.identifier] = start_node
    grid_dict[goal_node.identifier] = goal_node
    # create a test grid
    for y in range(grid_size):
        for x in range(grid_size):
            # exclude start and goal
            if (x, y) not in [(0, 0), (grid_size - 1, grid_size - 1)]:
            # randomly decide if the current node is an obstacle
                if random.random() >= obstacle_probability:
                    # assigns x,y coords to our identifier node
                    grid_dict[(x, y)] = Node(identifier = (x, y), x = x, y = y)

    for x in range(grid_size):
        for y in range(grid_size):
            if (x, y) in grid_dict:
                node = grid_dict[(x, y)]

                # add edges only if not an obstacle
                if x > 0 and (x - 1, y) in grid_dict: # left
                    node.add_neighbor(grid_dict[(x - 1, y)])
                if x < grid_size - 1 and (x + 1, y) in grid_dict:  # right
                    node.add_neighbor(grid_dict[(x + 1, y)])
                if y > 0 and (x, y - 1) in grid_dict:  # up
                    node.add_neighbor(grid_dict[(x, y - 1)])
                if y < grid_size - 1 and (x, y + 1) in grid_dict:  # down
                    node.add_neighbor(grid_dict[(x, y + 1)])

    return grid_dict, start_node, goal_node

def scale_test(grid_size, obstacle_probability):
    grid, start_node, goal_node = create_grid(grid_size, obstacle_probability)

    # make sure not obstacles
    start_node = grid[(0, 0)]
    goal_node = grid[(grid_size - 1, grid_size -1)]
    # start timing
    start_time = time.time() 
    path = a_star_search(start_node, goal_node)
    # end timing
    end_time = time.time()

    execution_time = end_time - start_time
    if path:
        print_grid_with_path(grid, path, grid_size, start_node, goal_node)
        print(f'Grid size: {grid_size}')
        print(f'Execution time: {execution_time:.4f} seconds')
        print(f'Path length: {len(path)}')
    else:
        print("No path found")


def print_grid_with_path(grid, path, grid_size, start_node, goal_node):

    # iterate through our rows (y-coords)
    for y in range(grid_size):
        # iterate through our columns (x-coords)
        for x in range(grid_size):
            # grab our node at the current x, y
            node = grid.get((x, y))
            # '.' = empty cell, '#' = obstacle
            char = ' ' if node else '.'
            if node in path:
                # if not start or goal display a 0 for part of the path
                char = 'O' if node != start_node and node != goal_node else char
            if node == start_node:
                char = 'S'
            if node == goal_node:
                char = 'G'
            print(char, end = ' ')
        print()


scale_test(grid_size = 100, obstacle_probability = 0.2)
